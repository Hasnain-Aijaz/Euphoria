package com.music.euphoria.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
public class MediaService {

    private final Cloudinary cloudinary;

    public MediaService(Cloudinary cloudinary) {
        this.cloudinary = cloudinary;
    }

    /**
     * Uploads an image file to Cloudinary.
     * @param file The image file to upload.
     * @return The secure URL of the uploaded image.
     */
    public String uploadImage(MultipartFile file) throws IOException {
        Map uploadResult = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.asMap("resource_type", "image"));
        return (String) uploadResult.get("secure_url");
    }

    /**
     * Uploads an audio file to Cloudinary.
     * @param file The audio file to upload.
     * @return The secure URL of the uploaded audio.
     */
    public String uploadAudio(MultipartFile file) throws IOException {
        Map uploadResult = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.asMap("resource_type", "video")); // Cloudinary treats audio as 'video' resource type
        return (String) uploadResult.get("secure_url");
    }
}
