# helloquarkus

Crie um Rest controller, incluindo as APIs:

    /hello: Retorne uma mensagem de Hello!
    /hello/{nome}: Receba um nome como parâmetro e retorne “Hello {nome}!”
    /hello/{nome}/horario: Receba um nome como parâmetro e retorne “Hello {nome}! Agora são {Horario}, não esqueça!".

Para a lógica do horário, faça em uma classe de serviço (@Service) e instancie o mesmo na sua classe Controller usando @Autowired.

Para todas as APIs, não esqueça de um log! Use o nível de log que achar apropriado. 
