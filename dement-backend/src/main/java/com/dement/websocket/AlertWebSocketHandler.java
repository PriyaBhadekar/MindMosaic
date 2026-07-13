package com.dement.websocket;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;

@Component
@RequiredArgsConstructor
@Slf4j
public class AlertWebSocketHandler extends TextWebSocketHandler {

    private final WebSocketSessionManager sessionManager;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String caregiverIdStr = session.getUri().getQuery();
        if (caregiverIdStr != null && caregiverIdStr.startsWith("caregiverId=")) {
            Long caregiverId = Long.parseLong(caregiverIdStr.replace("caregiverId=", ""));
            sessionManager.addSession(caregiverId, session);
            session.sendMessage(new TextMessage("{\"type\":\"CONNECTED\",\"message\":\"Connected to Dement Alert System\"}"));
            log.info("Caregiver {} connected to alert WebSocket", caregiverId);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        sessionManager.caregiverSessions().forEach((id, s) -> {
            if (s.getId().equals(session.getId())) {
                sessionManager.removeSession(id);
            }
        });
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        log.debug("Received WebSocket message: {}", message.getPayload());
    }

    public void sendAlertToCaregiver(Long caregiverId, String alertMessage) {
        if (sessionManager.hasSession(caregiverId)) {
            try {
                WebSocketSession session = sessionManager.getSession(caregiverId);
                String jsonMessage = String.format(
                        "{\"type\":\"SOS_ALERT\",\"message\":\"%s\",\"timestamp\":\"%s\"}",
                        alertMessage.replace("\"", "'"),
                        java.time.LocalDateTime.now()
                );
                session.sendMessage(new TextMessage(jsonMessage));
                log.info("Alert sent to caregiver {}: {}", caregiverId, alertMessage);
            } catch (IOException e) {
                log.error("Failed to send alert to caregiver {}: {}", caregiverId, e.getMessage());
            }
        } else {
            log.warn("Caregiver {} not connected to WebSocket. Alert not delivered in real-time.", caregiverId);
        }
    }
}