package com.dement;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class DementApplication {
    public static void main(String[] args) {
        SpringApplication.run(DementApplication.class, args);
    }
}