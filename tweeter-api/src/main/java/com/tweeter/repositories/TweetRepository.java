package com.tweeter.repositories;

import com.tweeter.models.Tweet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

@Repository
public interface TweetRepository extends JpaRepository<Tweet, Long> {
    
    /**
     * Busca tweets con paginación
     * @param pageable parámetros de paginación (page, size)
     * @return página de tweets ordenados por fecha de creación descendente
     */
    Page<Tweet> findAllByOrderByCreatedAtDesc(Pageable pageable);
}
