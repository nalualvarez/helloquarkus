package br.com.bb.t99.rest;

import br.com.bb.t99.services.GreetingService;
import org.jboss.logging.Logger;

import javax.inject.Inject;
import javax.inject.Named;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
@Named("greetingService")
@Path("/hello")
public class GreetingResource {

    @Inject
    GreetingService service;


    @GET
    @Produces(MediaType.TEXT_PLAIN)
    @Path("/{name}/horario")
    public String horario(final @PathParam("name") String name) {
        LOG.info("Hello com nome e horario");
        return (service.greeting(name) + "! Agora sao "+ service.horario() + ", nao esqueca!");
    }

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    @Path("/{name}")
    public String greeting(final @PathParam("name") String name) {
        LOG.info("Hello com nome");
        return (service.greeting(name) + "!");
    }

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        LOG.info("Hello");
        return "" +
                "Hello";
    }

    private static final Logger LOG = Logger.getLogger(GreetingResource.class);
}

//o log  que coloquei é suficiente?
