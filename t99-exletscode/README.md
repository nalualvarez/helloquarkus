# t99-exletscode

1. [Projeto](#1-projeto)
2. [Executar](#2-executar)
3. [Componentes](#3-componentes)
4. [Testes](#4-testes)


O t99-exletscode é um microsserviço que ....(Insira aqui a descrição da sua aplicação)

Este projeto é codificado em Java e utiliza o framework [Quarkus](<https://quarkus.io/>).

**Atenção**: Esse documento deve servir como guia para novos desenvolvedores por isso sempre manter ele atualizado com as dependencias necessarias para se executar esse projeto, 
como por exemplo as configurações das variaveis de ambiente (environments) e os sistemas que ele precisa para funcionar corretamente, como curio, rotinas de banco, etc...



Aplicação: 

As configurações sensiveis desse projeto ficam em variaveis de ambiente que estão localizadas nos arquivos .env.
**Atenção**: Esses arquivos não devem ser comitados no repositorio, eles devem estar no .gitignore do seu projeto, pois podem possuir senhas 
e configurações privadas a equipe de desenvolvimento.

Conteudo do arquivo .env

| Nome da Env                 | Descrição do valor                 | Valor Padrão |
|:----------------------------|:-----------------------------------|:-------------|
| QUARKUS_DATASOURCE_USERNAME | Nome do usuario de banco de dados  | ""           |
| QUARKUS_DATASOURCE_PASSWORD | Senha do usuario de banco de dados | ""           |
| QUARKUS_DATASOURCE_JDBC_URL | url de conexão do banco de dados   | ""           |




Para executar esse projeto foi criado um script na pasta `/run`, chamado `run.sh`.
Ele centraliza algumas ações, como a verificação se seu sistema operacional possui as configurações necessarias,
realiza a atualização do settings.xml com seu usuario e senha para autenticar no atf.
Possui a opção de executar o projeto usando o docker compose ou executar localmente e com a opção de subir uma instancia do Curio usando o 
docker caso precise de se comunicar com o iib.
Esses comandos estão descritos na inicialização do script.

Ele depende do `maven-wrapper` para realizar o build e este por sua vez depende da existencia do arquivo settings.xml localizado
na pasta `.m2` que fica no home do usuario.
O `maven-wrapper` é um tipo de maven stand-alone que não precisa de instalação, ele utiliza um script localizado na raiz do projeto, o `mvnw`
 e uma pasta `.mvn` que possui as configurações para baixar o `maven-wrapper.jar` e executa-lo.

Para executar o script, utilize o comando abaixo, na pasta raiz do projeto:

```bash 
./run/run.sh             
```

Caso ocorra a execução dos scripts apresente o erro `-bash: cd: /run/run.sh: Not a directory` altere a permissão do arquivo para permitir 
sua execução e tente novamente, conforme os comandos abaixo:

``` bash
chmod +x ./run/run.sh 
chmod +x mvnw
./run/run.sh 
```


Se preferir é possivel executar o aplicação sem o script run, apenas com o comando abaixo:

```shell
./mvnw compile quarkus:dev
```

Esse comando executa o quarkus no modo dev, sem nenhuma outra dependencia.
Ao executar dessa maneira confira o arquivo `.env` na raiz do projeto e verifique se todas suas configurações estão corretas.
Pois ao executar esse comando ele ira carregar todas as enviromnents presentes no arquivo.



Em qualquer um dos casos de execução, para verificar se sua aplicação subiu corretamente, verifique se o script esta em execução e ou
acesso o endereco (http://localhost:8080/)[http://localhost:8080/] nele você ira visualizar a tela inicial da aplicação com as informações
sobre sua aplicação e outros links, mas isso apenas quando executar no modo dev




Esta apliçação foi criada usando o `bb-dev-generator` que ja cria uma configuração inicial do projeto com os seguintes componentes:


| Componente | Descrição                                            | Endpoint                         | Saiba mais em                   |
|:-----------|:-----------------------------------------------------|:---------------------------------|:--------------------------------|
| *Index*    | Pagina Index da aplicação                            | [http://localhost:8080]          | [index](#31-index)              |
| *Info*     | Informaçoes da aplicacao                             | [http://localhost:8080/info]     | [info](#32-info)                |
| *Docs*     | Documentação da api                                  | [http://localhost:8080/api-docs] | [info](#33-documentacao-da-api) |
| *Metrica*  | Metricas expostas pela aplicação                     | [http://localhost:8080/metrics]  | [info](#34-metricas)            |
| *Health*   | Indica a situaçao da aplicação usando na monitoração | [http://localhost:8080/health]   | [info](#31-info)                |
| *Tracing*  | Verificar rastreamento de uma requisição             | [http://localhost:16686]         | [info](#31-info)                |


Essa é uma pagina html fixa com varias informações sobre sua aplicação, ela contem links sobre os principais recursos da aplicação e outras informações.


E um endpoint que retornar a informação da versão a aplicação e o nome da aplicação, ele é gerado pela biblioteca dev-java-erro automaticamente.
Esse endpoint fica disponivel em (http://localhost:8080/info)[http://localhost:8080/info].


A api deste projeto pode ser documentada usando a especificação [`open-api`](https://github.com/eclipse/microprofile-open-api/blob/master/spec/src/main/asciidoc/microprofile-openapi-spec.asciidoc),
nele temos as anotações e as configurações que se pode fazer para gerar a pagina do swagger, além desse temos a documentação do [quarkus](https://quarkus.io/guides/openapi-swaggerui).
O projeto foi configurada para que o endereco do Swagger UI fique disponivel no endereço: [http://localhost:8080/api-docs/](http://localhost:8080/api-docs/).
Também foi feito a configuração para sempre mostrar a pagina do swagger pela propriedade `quarkus.swagger-ui.always-include` presente no application.properties. 


As metricas desse projeto são geradas pela extensão [`quarkus-monitor`]() no padrão B5, que por sua vez são expostas no endpoint [http://localhost:8080/metrics](http://localhost:8080/metrics).

Para monitorar as métricas  no ambiente corporativo, são utilizadas as ferramentas [Prometheus](<https://prometheus.io/docs/introduction/overview/>) e [Grafana](<http://docs.grafana.org/>), 
e as mesmas ja estão disponiveis no ambiente do banco para mais informações [acesse](https://fontes.intranet.bb.com.br/dev/publico/roteiros#metricas).

Para conhecer mais sobre "Os 4 Sinais de Ouro" ("The Four Golden Signals") da monitoração, clique [aqui](https://landing.google.com/sre/sre-book/chapters/monitoring-distributed-systems/).


Para que o [Kubernetes](<https://kubernetes.io/pt/>) possa monitorar a saúde da aplicação, foram incluidos dois endpoints (/health e /ready) com os seguintes objetivos:

1. [/health/live:](<http://localhost:8080/health/live>) testar quando a aplicação está "viva";
2. [/health/ready:](<http://localhost:8080/health/ready>) testar se a aplicação está pronta para atender.

**Atenção:** o **/health** deve ser o mais simples possível de forma a não comprometer a monitoração pelo Kubernetes.

Eles foram incluidos utilizando a extensão [smallrye-health](https://quarkus.io/guides/smallrye-health).


O tracing esta configurado neste projeto com a extensão [`open-tracing`](https://quarkus.io/guides/opentracing) do quarkus.
Para utiliza-la voce pode usar as anotações do padrão [`open-tracing`](https://download.eclipse.org/microprofile/microprofile-opentracing-2.0/microprofile-opentracing-spec-2.0.html).
O resultado do tracing só é possivel de ser consultado se exitir uma aplicação para receber os dados, no caso estamos utilizando o `jaeger`.
A biblioteca `dev-java-erro` que esta neste projeto esta incluindo no span o requestId usado no log e retorno da mensagem de erro facilitando
a rastreabilidade do erro.
Para maiores informações [acesse o roteiro](https://fontes.intranet.bb.com.br/dev/publico/roteiros#monitora%C3%A7%C3%A3o-log-e-trace)

**Atenção:** não sobrecarrege o span com muitas informações pois isso pode gerar uma carga execessiva no servidor que ira receber essas informações.


Os testes neste projeto devem ser feitos utilizando a versão 5 do Junit e com as anotações de teste do proprio quarkus.
A cobertura é feita utilizando o jacoco e ja esta configurado no pom.xml.

As classes de teste devem ficar na pasta: **/src/test/** e seguir a mesma organização das pastas do projeto.

Os testes vão executados sempre quando a aplicação foi construida, isso ocorre quando voce executar o script `./run/run.sh` com o comando
para executar com o docker compose.

Quando executar no modo local ele vai subir a aplicação sem executar os testes, contudo a versão 2 do quarkus permite a execução dos testes
durante o desenvolvimento, com as opções que são apresentadas no terminal

Caso precise executar os testes para verificar a cobertura execute o comando `test` ou `verify` do maven como nos exemplos abaixo:

``` bash
.\mvnw clean test
```

``` bash
.\mvnw clean verify
```

Se os testes executarem com sucesso o resultado da cobertura ficara localizado em `/target/site/jacoco/index.html`
#   h e l l o q u a r k u s  
 