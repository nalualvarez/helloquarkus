#!/bin/bash
set -e

# Função para verificar se existe alguma imagem de curio com o nome CURIO em execução
# se existir ele vai parar a imagem e subir uma nova com as envs definidas no .env_curio
function startCurio() {
  printf '========================== INICIANDO EXECUCAO DO CURIO NO DOCKER ==========================\n'
  printf '\n'
  DOCKER_CURIO=`docker ps -a | grep CURIO | wc -l`
  if [[ ${DOCKER_CURIO} -ge 1 ]]; then
    stopCurio
  fi
  printf '==================================== DOCKER RUN CURIO =====================================\n'
  docker run -d -p 8081:8081 --env-file "$PWD"/.env_curio --name CURIO --rm atf.intranet.bb.com.br:5001/bb/iib/iib-curio:0.6.5
}

# Funcao para parar a execução do curio
function stopCurio() {
  printf '======================================= CURIO STOP ========================================\n'
  printf '\n'
  docker stop CURIO
}

# Verifica as configurações, se possui java na versao correta e configura o settings.xml
function verificaConfig() {
  printf '\n'
  printf '=========================== VERIFICANDO CONFIGURAÇÃO DO SISTEMA ===========================\n'

  baixarDevJavaConfig $2

  JAVA_VERSAO=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)

  if [[ ${JAVA_VERSAO} -le 10 ]]; then
    printf "Não foi encontrado Java configurado na sua máquina ou a versão do JAVA_HOME é anterior à 11. Configure o Java 11 ou superior e tente novamente."
    exit 1
  fi

  printf "Foi encontrado a versão '${JAVA_VERSAO}' do java em seu sistema.\n"
  if [[ "$1" == "true" ]]; then
    printf "Informe a sua senha de sudo da maquina:\n"
    sudo java -Duser.home=$HOME -jar "$PWD"/run/dev-java-config.jar
    STATUS_JAVA_CONFIG="${?}"
  else
    java -jar "$PWD"/run/dev-java-config.jar
    STATUS_JAVA_CONFIG="${?}"
  fi

  if [[ ${STATUS_JAVA_CONFIG} != 0 ]]; then
    printf "Não foi possivel executar a configuração do settings do maven e ou certificados do cacerts do java \n"
    exit 1
  fi
}

# Executa a aplicação usando o docker compose usando o arquivo docker-compose.yaml
function executaDockerCompose() {
  printf "\n"
  printf '============================= MODO DOCKER COMPOSE SELECIONADO ==============================\n'
  printf "\n"
  printf '============================= REALIZANDO O BUILD DA APLICAÇÃO ==============================\n'
  printf "\n"
  ./mvnw clean install
  printf '=============================== INICIANDO O DOCKER COMPOSE ================================\n'
  if [[ $1 == "true" ]]; then
     export DB_USER_PES=$USER_DB2
     export DB_PASSWORD_PES=$PASSWORD_DB2
  fi

  docker-compose --env-file .env -f "$PWD"/run/docker-compose.yaml up --build

  if [[ $1 == "true" ]]; then
    unset DB_USER_PES
    unset DB_PASSWORD_PES
  fi

}

# desligar o Docker compose
function executaDockerComposeDown() {
  printf "\n"
  printf '====================== EXECUTANDO O DOCKER COMPOSE DOWN APOS CTRL+C =======================\n'
  docker-compose -f "$PWD"/run/docker-compose.yaml down
  exit
}

# Executa a aplicação no MODO local executando o quarkus no MODO dev
function executaModoLocal() {
  printf "\n"
  printf '================================= MODO LOCAL SELECIONADO ==================================\n'
  printf '============================ EXECUTANDO APLICACAO NO MODO DEV =============================\n'
  if [[ $1 == "true" ]]; then
    ./mvnw compile quarkus:dev -DQUARKUS_DATASOURCE_USERNAME=$USER_DB2 -DQUARKUS_DATASOURCE_PASSWORD=$PASSWORD_DB2
  else
    ./mvnw compile quarkus:dev
  fi
}

function solicitarUsuarioPessoalDb2(){
  echo "Informe sua matricula para acesso ao DB2"
  read -r -p "Matricula: " USER_DB2
  # mudar para minusculo
  if [[ -z "USER_DB2" ]]; then
    echo "Por favor informe a chave do usuário em minúsculo (F/C/E/T/Z) "
    exit 1
  fi
  if [[ "${USER_DB2}" -gt 8 ]]; then
    echo "Por favor informe a matricula com até 8 caracteres."
    exit 1
  fi
  read -r -sp "Senha do SisBB: " PASSWORD_DB2
  if [[ -z "PASSWORD_DB2" ]]; then
    echo "Por favor informe a senha."
    exit 1
  fi
  echo
}

function baixarDevJavaConfig() {
  if [ -r "$BASE_DIR/run/dev-java-config.jar" ]; then
     echo "Encontrou o arquivo dev-java-config.jar."
  else
    echo "Não encontrou o arquivo dev-java-config.jar, iniciando o download de " $1
    LINK=$1
    set +e
    CODE=$(curl -w %{http_code} -s "${LINK}" -o ./run/dev-java-config.jar)
    ERRO=$?
    set -e
    if [[ "$CODE" =~ ^2 ]]; then
      echo "Baixou o dev-java-config.jar com sucesso"
    else
      echo "Não foi possivel baixar o dev-java-config.jar, retornou status code: $CODE."
      echo "O comando curl retornou o erro: $ERRO . Erros do curl: https://curl.se/libcurl/c/libcurl-errors.html"
      echo "Tente baixar manualmente do endereço $1 e coloque dentro da pasta run do projeto."
      rm -rf ./run/dev-java-config.jar
      exit 1
    fi
  fi
}

function removerMavenWrapperCorrompido() {
    WRAPPER_CORROMPIDO=`find . -name "maven-wrapper.jar" -size -1k | grep /.mvn/wrapper/maven-wrapper.jar | wc -l`
    if [[ ${WRAPPER_CORROMPIDO} -ge 1 ]]; then
      printf "\n"
      printf "Excluindo maven-wrapper corrompido, possivelmente voce nao esta conseguindo acessar\n"
      printf " o repositorio do atf, realize a copia manual do link abaixo para a pasta \n"
      printf " .mvn/wrapper/ \n"
      printf "http://atf.intranet.bb.com.br/artifactory/bb-maven-repo/org/apache/maven/wrapper/maven-wrapper/3.1.0/maven-wrapper-3.1.0.jar \n"
      find . -name "maven-wrapper.jar" -size -1k -delete
      printf "\n"
    fi
}

printf "===========================================================================================\n"
printf "======================= INICIANDO SCRIPT PARA EXECUÇÃO DA APLICACAO =======================\n"
printf "Script de configuração e validação do java e maven para permitir a execução da sua \n"
printf " aplicação com três possibilidades de execução:\n"
printf "\n"
printf "1- Padrão: quando não se informa o modo execução, sua aplicação será executada no modo dev \n"
printf "   do quarkus usando o comando ./mvnw compile quarkus:dev, permitindo o uso do quarkus-cli.\n"
printf "   Nesse modo o script ira executar apenas sua aplicação.\n"
printf "\n"
printf "2- Com curio: realiza duas ações, a primeira executa o docker-run para subir o curio na   \n"
printf "   versão 0.6.5, caso queria atualizar substituia todas as ocorrencias dentro do projeto. \n"
printf "   a segunda é a execução aplicação no modo dev do quarkus usando o comando:              \n"
printf "   ./mvnw compile quarkus:dev permitindo o uso do quarkus-cli.  \n"
printf "   Para ver o log do curio, em outro terminal use o comando 'docker logs -f CURIO' assim  \n"
printf "   pode ver se o CURIO subiu corretamente, outra opção é acessar o localhost:8081/health, \n"
printf "   isso se seu curio estiver configurado na porta 8081, ou na porta configurada do curio. \n"
printf "\n"
printf "3- Com docker-compose: utiliza a configuração localizado em /run/docker-compose.yaml para \n"
printf "   subir varias imagens docker, com o curio, jaeger e também construir uma imagem da      \n"
printf "   aplicação, nesse modo o quarkus executa no modo prod, o mesmo usado nos ambientes de   \n"
printf "   deploy (Desenv, Homologa, Produção) e sem a opção de hot-deploy e sem o quarkus-cli.   \n"
printf "\n"
printf "\n"
printf "*Esse script pode ser atualizado executando o script update-run.sh, ele vai realizar a    \n"
printf "  substituição do arquivo localizado em /run/run.sh, copiando do endereço do link abaixo  \n"
printf "  Link: http://atf.intranet.bb.com.br/artifactory/bb-binarios-local/dev/scripts/run.sh    \n"
printf "\n"
printf "Comandos de configuração: \n"
printf "\n"
echo "-b  : MODO Banco de Dados com usuario SISBB que possua acesso as tabelas, usar apenas se não "
printf "        possuir um usuario impessoal para acesso ao banco.\n"
echo "-f  : MODO forçado, ignora a configuração e validação do java e do settings.xml pelo ."
printf "        dev-java-config.\n"
echo "-s  : MODO que executa o dev-java-config com permissão de sudo, usar somente quando houver erro"
printf "        de acesso negado nos certificados do java.\n"
printf "\n"
printf "Comandos de execução: \n"
printf "\n"
echo "-c  : MODO CURIO, executa o docker run para a imagem do CURIO com as configurações localizadas "
printf "        no arquivo .env_curio na raiz do projeto. \n"
printf "        Deve usar esse modo quando sua aplicação possuir integração com o IIB, tanto para \n"
printf "        consumir ou prover operação. \n"
echo "-dc : MODO DOCKER-COMPOSE, executa sua aplicação com o docker-compose, deve ser usado para "
printf "        testar a imagem docker que vai ser usada em produção, nesse modo ele não permite   \n"
printf "        a execução do hot-deploy do quarkus, utilize esse modo para validar suas configurações. \n"

printf "*Obs:Se os dois modos de execução forem informados, apenas o modo CURIO será executado.\n"
printf "===========================================================================================\n"

export MVNW_REPOURL="http://atf.intranet.bb.com.br/artifactory/bb-maven-repo"

DEV_JAVA_CONFIG_URL='http://atf.intranet.bb.com.br/artifactory/bb-binarios-local/dev/dev-java-config/dev-java-config.jar'
MODO_FORCADO="false"
MODO_SUDO="false"
MODO_CURIO="false"
MODO_COMPOSE="false"
MODO_BD_IMP="false"

while [ $# -gt 0 ]; do
    case $1 in
    -s) MODO_SUDO="true"
      shift
      ;;
    -f) MODO_FORCADO="true"
      shift
      ;;
    -dc) MODO_COMPOSE="true"
      shift
      ;;
    -c) MODO_CURIO="true"
      shift
      ;;
    -b) MODO_BD_IMP="true"
      shift
      ;;
    *) echo "Opção $1 Invalida!"
      shift
      ;;
    esac
done

if [[ ${MODO_FORCADO} == "false" ]]; then
  verificaConfig ${MODO_SUDO} ${DEV_JAVA_CONFIG_URL}
fi

# Muda para o arquivo para formato linux LF
vim mvnw -c "set ff=unix" -c ":wq"
# Verifica se o wrapper esta ok
removerMavenWrapperCorrompido

if [[ ${MODO_BD_IMP} == "true" ]]; then
  solicitarUsuarioPessoalDb2
fi

if [[ ${MODO_COMPOSE} == "true" && ${MODO_CURIO} == "false" ]]; then
  trap executaDockerComposeDown INT
  executaDockerCompose $MODO_BD_IMP
  executaDockerComposeDown
fi

if [[ ${MODO_CURIO} == "true" && ${MODO_COMPOSE} == "false" ]]; then
  trap stopCurio INT
  startCurio
fi

if [[ ${MODO_COMPOSE} == "false" || ${MODO_CURIO} == "true" ]]; then
  executaModoLocal $MODO_BD_IMP
fi

if [[ ${MODO_CURIO} == "true" && ${MODO_COMPOSE} == "false" ]]; then
  stopCurio
fi
