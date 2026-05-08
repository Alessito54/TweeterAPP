package com.tweeter.controllers;

import com.tweeter.models.Tweet;
import com.tweeter.repositories.TweetRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/tweets")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class TweetController {

    @Autowired
    private TweetRepository tweetRepository;

    /**
     * GET /api/tweets - Obtiene todos los tweets con paginación
     * Parámetros de query:
     * - page: número de página (default: 0)
     * - size: cantidad de registros por página (default: 10)
     * - sort: campo para ordenar (default: createdAt,desc)
     *
     * @param page número de página
     * @param size cantidad de registros
     * @return página de tweets con código 200
     */
    @GetMapping
    public ResponseEntity<Page<Tweet>> getAllTweets(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Tweet> tweets = tweetRepository.findAllByOrderByCreatedAtDesc(pageable);
        return ResponseEntity.ok(tweets);
    }

    /**
     * GET /api/tweets/{id} - Obtiene un tweet específico por su ID
     *
     * @param id ID del tweet
     * @return el tweet si existe, 404 si no
     */
    @GetMapping("/{id}")
    public ResponseEntity<Tweet> getTweetById(@PathVariable Long id) {
        Optional<Tweet> tweet = tweetRepository.findById(id);
        if (tweet.isPresent()) {
            return ResponseEntity.ok(tweet.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * POST /api/tweets - Crea un nuevo tweet
     *
     * @param tweet objeto Tweet con validaciones (@NotBlank, @Size max 140)
     * @return el tweet creado con código 201
     */
    @PostMapping
    public ResponseEntity<Tweet> createTweet(@Valid @RequestBody Tweet tweet) {
        Tweet savedTweet = tweetRepository.save(tweet);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedTweet);
    }

    /**
     * PUT /api/tweets/{id} - Actualiza un tweet existente
     *
     * @param id ID del tweet a actualizar
     * @param tweetDetails nuevos datos del tweet
     * @return el tweet actualizado o 404 si no existe
     */
    @PutMapping("/{id}")
    public ResponseEntity<Tweet> updateTweet(
            @PathVariable Long id,
            @Valid @RequestBody Tweet tweetDetails) {
        Optional<Tweet> optionalTweet = tweetRepository.findById(id);
        if (optionalTweet.isPresent()) {
            Tweet tweet = optionalTweet.get();
            tweet.setTweet(tweetDetails.getTweet());
            Tweet updatedTweet = tweetRepository.save(tweet);
            return ResponseEntity.ok(updatedTweet);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * DELETE /api/tweets/{id} - Elimina un tweet
     *
     * @param id ID del tweet a eliminar
     * @return 204 No Content si se eliminó correctamente, 404 si no existe
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTweet(@PathVariable Long id) {
        if (tweetRepository.existsById(id)) {
            tweetRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * DELETE /api/tweets - Elimina todos los tweets
     * ADVERTENCIA: Esta operación es destructiva
     *
     * @return 204 No Content
     */
    @DeleteMapping
    public ResponseEntity<Void> deleteAllTweets() {
        tweetRepository.deleteAll();
        return ResponseEntity.noContent().build();
    }
}
