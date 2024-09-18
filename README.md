# :whale: Análise de dados com PySpark
Este projeto consiste em analisar conjuntos de dados do mundo real usando PySpark em um ambiente dockerizado, usando as seguintes ferramentas:
- PySpark (3.5.1)
- Delta Lake (3.2.0)
- MinIO (AGPL v3) :flamingo:
- Jupyter Lab

# :card_index_dividers:	Dataset's
Os dados brutos são armazenados na camada raw do MinIO :flamingo:
- :white_check_mark: Record Linkage Comparison Patterns https://bit.ly/1Aoywaq

### Build e start containers
Primeiro, você precisa construir uma imagem docker digitando `make build`. Depois disso, digite `make start` toda vez que quiser iniciar o serviço.

### Usando Jupyter
Após a conclusão do processo de construção e inicialização, digite `make token` e copie o resultado.

Acesse [http://localhost:8888](http://localhost:8888), cole o token no campo text/password e envie. Se tudo estiver certo, agora você tem acesso ao Jupyter Lab e pode criar scripts python normalmente.

### Acesse MinIO
Acesse [http://localhost:9000](http://localhost:9000) e faça login usando estas credenciais:
- username: minioadmin
- passsword: minioadmin

Agora você pode criar seus próprios buckets para salvar e manipular arquivos como um AWS S3 :wine_glass:.

### Acessando Spark Web UI
Acesse [http://localhost:8080](http://localhost:8080) para inspecionar aplicativos e workers do PySpark (por padrão, o `docker-compose.yml` é configurado para executar 1 worker do PySpark com 1 vCore e 1 GB de memória cada).

Para inspecionar os estágios de execução, você pode acessar [http://localhost:4040](http://localhost:4040) durante a execução.

### Stop containers
Para parar todos os contêineres, digite `make stop` no terminal e espere que todos eles sejam baixados.

## :package: Volumes
Os exemplos estão no diretório `workspace/` na raiz do projeto. Esta pasta é compartilhada entre a máquina host e o jupyter workspace em execução dentro do contêiner.

