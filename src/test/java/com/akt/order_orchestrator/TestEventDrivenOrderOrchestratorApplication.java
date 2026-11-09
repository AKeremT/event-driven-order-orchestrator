package com.akt.order_orchestrator;

import org.springframework.boot.SpringApplication;

public class TestEventDrivenOrderOrchestratorApplication {

	public static void main(String[] args) {
		SpringApplication.from(EventDrivenOrderOrchestratorApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
