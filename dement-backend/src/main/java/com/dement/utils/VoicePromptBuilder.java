package com.dement.utils;

import com.dement.enums.MoodType;
import org.springframework.stereotype.Component;

import java.time.LocalTime;
import java.util.List;
import java.util.Random;

@Component
public class VoicePromptBuilder {

    private final Random random = new Random();

    private static final List<String> MORNING_PROMPTS = List.of(
            "Good morning! How are you feeling today?",
            "Good morning! Did you sleep well last night?",
            "Rise and shine! Are you ready for a new day?",
            "Good morning! Would you like to have breakfast now?"
    );

    private static final List<String> AFTERNOON_PROMPTS = List.of(
            "Good afternoon! Did you eat lunch today?",
            "How are you feeling this afternoon?",
            "Have you had enough water to drink today?",
            "Would you like to take a short walk today?"
    );

    private static final List<String> EVENING_PROMPTS = List.of(
            "Good evening! How was your day?",
            "It's evening time. Did you take your medicine today?",
            "Would you like to listen to some relaxing music?",
            "Good evening! Are you feeling comfortable?"
    );

    public String getWellnessPrompt() {
        LocalTime now = LocalTime.now();
        if (now.isBefore(LocalTime.NOON)) {
            return MORNING_PROMPTS.get(random.nextInt(MORNING_PROMPTS.size()));
        } else if (now.isBefore(LocalTime.of(17, 0))) {
            return AFTERNOON_PROMPTS.get(random.nextInt(AFTERNOON_PROMPTS.size()));
        } else {
            return EVENING_PROMPTS.get(random.nextInt(EVENING_PROMPTS.size()));
        }
    }

    public String getMoodBasedSuggestion(MoodType mood) {
        return switch (mood) {
            case SAD -> "I notice you're feeling sad. Would you like to listen to your favorite music, or perhaps call a family member?";
            case ANXIOUS -> "It seems like you're feeling anxious. Let's try some calming music. Would you like that?";
            case CONFUSED -> "Don't worry, you're safe at home. Would you like to see some photos of your family?";
            case AGITATED -> "I understand. Let's listen to some peaceful music to help you relax.";
            case HAPPY -> "That's wonderful! You're feeling happy today! Would you like to play a game?";
            case CALM -> "I'm glad you're feeling calm. Would you like to continue with your daily activities?";
            default -> "How are you doing? I'm here if you need anything.";
        };
    }

    public String buildSchedulePrompt(String title, String description) {
        return String.format("Reminder: %s. %s", title,
                description != null ? description : "Please complete this activity when you're ready.");
    }
}