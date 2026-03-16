package com.report.engine;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ReportEngineApplication {

    public static void main(String[] args) {
        SpringApplication.run(ReportEngineApplication.class, args);
        System.out.println("===> Report Engine Started successfully! <===");
    }
}
