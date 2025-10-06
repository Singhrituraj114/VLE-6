package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String hello() {
        return "Hello World! CI/CD Pipeline is working successfully!";
    }

    @GetMapping("/health")
    public String health() {
        return "Application is healthy and running!";
    }

    @GetMapping("/version")
    public String version() {
        return "Version: 1.0.0 - Build: " + System.getenv("BUILD_NUMBER");
    }
}