FROM openjdk:17-slim

# Install essential dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget curl

ENV PYTHON_VERSION 3.11.8

RUN curl -O https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \  
    && tar xzf Python-$PYTHON_VERSION.tgz \
    && cd Python-$PYTHON_VERSION \ 
    && ./configure \
    && make -j $(nproc) \
    && make install \
    && rm -rf Python-$PYTHON_VERSION.tgz Python-$PYTHON_VERSION

# Setup Python version
ENV PYTHONHASHSEED 1
ENV PYSPARK_PYTHON python3

RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# Download and setup Spark
ENV SPARK_HOME /opt/spark

RUN mkdir -p ${SPARK_HOME} && \
    curl -o /tmp/spark.tgz "https://dlcdn.apache.org/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz" && \
    tar -xf /tmp/spark.tgz -C ${SPARK_HOME} --strip-components=1 && \
    rm /tmp/spark.tgz

ENV PATH       ${PATH}:${SPARK_HOME}/bin
ENV PATH       ${PATH}:${SPARK_HOME}/sbin
ENV PYTHONPATH ${PYTHONPATH}:${SPARK_HOME}/python
ENV PYTHONPATH ${PYTHONPATH}:${SPARK_HOME}/python/lib/py4j-0.10.9.5-src.zip

## Default workload configurations
ENV SPARK_WORKLOAD          master
ENV SPARK_MASTER_HOST       spark-master-container
ENV SPARK_MASTER_PORT       7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_WORKER_WEBUI_PORT 8081

## Log configurations
ENV SPARK_LOG_DIR    ${SPARK_HOME}/logs
ENV SPARK_MASTER_LOG ${SPARK_LOG_DIR}/spark-master.out
ENV SPARK_WORKER_LOG ${SPARK_LOG_DIR}/spark-worker.out

RUN mkdir -p ${SPARK_LOG_DIR} \
    && touch ${SPARK_MASTER_LOG} \
    && touch ${SPARK_WORKER_LOG} \
    && ln -sf /dev/stdout ${SPARK_MASTER_LOG} \
    && ln -sf /dev/stdout ${SPARK_WORKER_LOG}

## Expose mandatory ports
EXPOSE 4040 6066 7077 8080 8081

# Install Jupyter
ENV JUPYTERLAB_PORT      8888
ENV JUPYTERLAB_WORKSPACE /root/.jupyter/workspace
ENV JUPYTERLAB_PID       /root/.jupyter/pid

RUN pip3 install jupyterlab py4j pyarrow pandas && \
    jupyter lab --generate-config

## Log configurations
ENV JUPYTERLAB_LOG_DIR   /root/.jupyter/logs
ENV JUPYTERLAB_LOG       ${JUPYTERLAB_LOG_DIR}/jupyter.out

RUN mkdir -p ${JUPYTERLAB_LOG_DIR} && \
    touch ${JUPYTERLAB_LOG} && \
    ln -sf /dev/stdout ${JUPYTERLAB_LOG}

# Ignore WARN MetricsConfig
RUN touch ${SPARK_HOME}/conf/hadoop-metrics2-s3a-file-system.properties

COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# Start master or worker
COPY --chmod=0755 start-spark.sh .

CMD ["/start-spark.sh"]