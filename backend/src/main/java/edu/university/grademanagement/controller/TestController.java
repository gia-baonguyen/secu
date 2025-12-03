package edu.university.grademanagement.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/test")
public class TestController {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/hash/{password}")
    public String generateHash(@PathVariable String password) {
        String hash = passwordEncoder.encode(password);
        return "Password: " + password + "\nHash: " + hash + "\nLength: " + hash.length();
    }

    @GetMapping("/verify")
    public String verifyPassword(@RequestParam String password, @RequestParam String hash) {
        boolean matches = passwordEncoder.matches(password, hash);
        return "Password: " + password + "\nHash: " + hash + "\nMatches: " + matches;
    }
}
