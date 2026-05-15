package com.music.euphoria;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

//Created this to disable security so i can test rest api's on postman.

@SpringBootApplication
public class EuphoriaApplication {

    public static void main(String[] args) {
        SpringApplication.run(EuphoriaApplication.class, args);
    }

}
