package com.dement.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import jakarta.annotation.PostConstruct;
import java.io.File;

@Configuration
public class FileStorageConfig {

    @Value("${app.upload.profile-dir}")
    private String profileDir;

    @Value("${app.upload.memory-dir}")
    private String memoryDir;

    @Value("${app.upload.song-dir}")
    private String songDir;

    @Value("${app.upload.mri-dir}")
    private String mriDir;

    @PostConstruct
    public void createDirectories() {
        createDir(profileDir);
        createDir(memoryDir);
        createDir(songDir);
        createDir(mriDir);
    }

    private void createDir(String path) {
        File dir = new File(path);
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }
}