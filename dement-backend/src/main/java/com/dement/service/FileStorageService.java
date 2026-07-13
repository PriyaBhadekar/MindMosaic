package com.dement.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
@Slf4j
public class FileStorageService {

    @Value("${app.upload.profile-dir}")
    private String profileDir;

    @Value("${app.upload.memory-dir}")
    private String memoryDir;

    @Value("${app.upload.song-dir}")
    private String songDir;

    @Value("${app.upload.mri-dir}")
    private String mriDir;

    public String storeProfileImage(MultipartFile file) {
        return storeFile(file, profileDir);
    }

    public String storeMemoryImage(MultipartFile file) {
        return storeFile(file, memoryDir);
    }

    public String storeSong(MultipartFile file) {
        return storeFile(file, songDir);
    }

    public String storeMriImage(MultipartFile file) {
        return storeFile(file, mriDir);
    }

    private String storeFile(MultipartFile file, String directory) {


        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File cannot be empty");
        }
        log.info("========== FILE DEBUG ==========");
        log.info("ORIGINAL NAME = {}", file.getOriginalFilename());
        log.info("FILE SIZE = {}", file.getSize());
        log.info("DIRECTORY = {}", directory);
        log.info("================================");
        String originalFilename = file.getOriginalFilename();

        String extension = "";

        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        String filename = UUID.randomUUID() + extension;

        try {

            Path dirPath = Paths.get(System.getProperty("user.dir"), directory);

            log.info("WORKING DIR = {}", System.getProperty("user.dir"));
            log.info("DIRECTORY = {}", directory);
            log.info("FINAL DIR = {}", dirPath.toAbsolutePath());

            Files.createDirectories(dirPath);

            Path targetPath = dirPath.resolve(filename);

            Files.copy(
                    file.getInputStream(),
                    targetPath,
                    StandardCopyOption.REPLACE_EXISTING
            );

            String storedPath = directory + "/" + filename;

            log.info("FILE STORED AT = {}", storedPath);

            return storedPath;

        } catch (IOException e) {

            log.error("FAILED TO STORE FILE {}", e.getMessage());

            throw new RuntimeException("Failed to store file");
        }
    }

    public void deleteFile(String filePath) {
        if (filePath == null) return;
        try {
            Path path = Paths.get(filePath);
            Files.deleteIfExists(path);
            log.info("File deleted: {}", filePath);
        } catch (IOException e) {
            log.warn("Could not delete file: {}", filePath);
        }
    }

    public byte[] getFileBytes(String filePath) throws IOException {
        Path path = Paths.get(filePath);
        return Files.readAllBytes(path);
    }
}