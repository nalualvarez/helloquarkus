#!/bin/bash
set -e

function baixarRunDoBinarios() {
  echo "Realizando o update do script run.sh."
  LINK=$1
  set +e
  CODE=$(curl -w %{http_code} -s "${LINK}" -o ./run/run.sh) | cat
  ERRO=$?
  set -e
  if [[ "$CODE" =~ ^2 ]]; then
    echo "Script run.sh atualizado com sucesso"
  else
    echo "Não foi possivel baixar o run.sh, retornou status code: $CODE."
    echo "O comando curl retornou o erro: $ERRO . Erros do curl: https://curl.se/libcurl/c/libcurl-errors.html"
    echo "Tente baixar manualmente do endereço $1 e coloque dentro da pasta run do projeto."
    exit 1
  fi
}

function atribuirComoExecutavel() {
    chmod +x "$BASE_DIR./run/run.sh"
}

function removerRunShCorrompido() {
    RUN_CORROMPIDO=`find . -name "run.sh" -size -1k | grep /run.sh | wc -l`
    if [[ ${RUN_CORROMPIDO} -ge 1 ]]; then
      printf "\n"
      printf "Excluindo run.sh corrompido, possivelmente voce nao esta conseguindo acessar o\n"
      printf " repositorio do atf, realize a copia manual do link abaixo para a pasta /run \n"
      echo $1
      find . -name "run.sh" -size -1k -delete
      printf "\n"
    fi
}

function removerDevJavaConfigCorrompido() {
    DEV_CONFIG_CORROMPIDO=`find . -name "dev-java-config.jar" -size -1k | grep /dev-java-config.jar | wc -l`
    if [[ ${DEV_CONFIG_CORROMPIDO} -ge 1 ]]; then
      printf "\n"
      printf "Excluindo dev-java-config.jar corrompido, possivelmente voce nao esta conseguindo acessar o\n"
      printf " repositorio do atf, realize a copia manual do link abaixo para a pasta /run \n"
      echo $1
      find . -name "dev-java-config.jar" -size -1k -delete
      printf "\n"
    fi
}

function baixarDevJavaConfig() {
  echo "Realizando o update do dev-java-config.jar."
  LINK=$1
  set +e
  CODE=$(curl -w %{http_code} -s "${LINK}" -o ./run/dev-java-config.jar) | cat
  ERRO=$?
  set -e
  if [[ "$CODE" =~ ^2 ]]; then
    echo "Script dev-java-config.jar atualizado com sucesso"
  else
    echo "Não foi possivel baixar o dev-java-config.jar, retornou status code: $CODE."
    echo "O comando curl retornou o erro: $ERRO . Erros do curl: https://curl.se/libcurl/c/libcurl-errors.html"
    echo "Tente baixar manualmente do endereço $1 e coloque dentro da pasta run do projeto."
    exit 1
  fi
}

printf "===========================================================================================\n"
printf "============== INICIANDO SCRIPT PARA ATUALIZAÇÃO DO RUN-SH E DEV-JAVA-CONFIG ==============\n"
printf "===========================================================================================\n"

RUN_SH_LINK='http://atf.intranet.bb.com.br/artifactory/bb-binarios-local/dev/scripts/run.sh'
DEV_CONFIG_LINK='http://atf.intranet.bb.com.br/artifactory/bb-binarios-local/dev/dev-java-config/dev-java-config.jar'

removerRunShCorrompido $RUN_SH_LINK
removerDevJavaConfigCorrompido $DEV_CONFIG_LINK
baixarRunDoBinarios $RUN_SH_LINK
baixarDevJavaConfig $DEV_CONFIG_LINK
atribuirComoExecutavel
removerRunShCorrompido $RUN_SH_LINK
removerRunShCorrompido $RUN_SH_LINK
