package org.acme.management.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonFormat.Shape;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    private BigDecimal id;

    @NotBlank(message = "The name must be informed")
    private String name;

    @JsonProperty(value = "date_of_birth")
    @Past(message = "The date of birth must be before the current date")
    @JsonFormat(shape = Shape.STRING, pattern = "yyyy-MM-dd")
    private Date dateOfBirth;

    @NotBlank(message = "The SSN number must be informed")
    private String ssn;

    @NotBlank(message = "The e-mail address must be informed")
    @Email(message = "The e-mail must must have a valid pattern")
    private String email;

}
