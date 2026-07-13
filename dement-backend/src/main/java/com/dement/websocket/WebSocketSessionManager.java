package com.dement.websocket;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class WebSocketSessionManager {

    private final Map<Long, WebSocketSession> caregiverSessions = new ConcurrentHashMap<>();

    public void addSession(Long caregiverId, WebSocketSession session) {
        caregiverSessions.put(caregiverId, session);
        log.info("WebSocket session added for caregiver: {}", caregiverId);
    }

    public void removeSession(Long caregiverId) {
        caregiverSessions.remove(caregiverId);
        log.info("WebSocket session removed for caregiver: {}", caregiverId);
    }

    public WebSocketSession getSession(Long caregiverId) {
        return caregiverSessions.get(caregiverId);
    }

    public boolean hasSession(Long caregiverId) {
        WebSocketSession session = caregiverSessions.get(caregiverId);
        return session != null && session.isOpen();
    }

    // Add this method to WebSocketSessionManager.java
    public Map<Long, WebSocketSession> caregiverSessions() {
        return caregiverSessions;
    }
}