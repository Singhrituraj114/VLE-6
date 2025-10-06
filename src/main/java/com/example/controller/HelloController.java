package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String hello() {
        return "🚀 VLE-6 CI/CD Pipeline - STEP 7 VERIFICATION! Build #" + System.getenv("BUILD_NUMBER");
    }

    @GetMapping("/health")
    public String health() {
        return "Application is healthy and running!";
    }

    @GetMapping("/version")
    public String version() {
        return "🎯 VLE-6 Complete Pipeline - Version: 2.0.0 - Build: " + System.getenv("BUILD_NUMBER");
    }
}