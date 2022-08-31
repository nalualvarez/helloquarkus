package br.com.bb.t99.services;


import javax.enterprise.context.ApplicationScoped;

import java.awt.*;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

@ApplicationScoped
public class GreetingService {

    public String greeting(String name) {
        return "Hello " + name;
    }

    public String horario() {
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("HH:mm");
        return String.valueOf(LocalTime.now().format(dtf));
    }

}