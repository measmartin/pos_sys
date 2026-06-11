using System.ComponentModel.DataAnnotations;

namespace PosApi.DTOs;

// Customer DTOs
public class CreateCustomerDto
{
    [Required]
    [StringLength(200, MinimumLength = 1, ErrorMessage = "Customer name must be 1-200 characters.")]
    public string? CustomerName { get; set; }

    [StringLength(20, ErrorMessage = "Phone number must be at most 20 characters.")]
    [Phone(ErrorMessage = "Invalid phone number.")]
    public string? PhoneNumber { get; set; }

    [StringLength(200, ErrorMessage = "Email must be at most 200 characters.")]
    [EmailAddress(ErrorMessage = "Invalid email address.")]
    public string? Email { get; set; }

    [StringLength(200, ErrorMessage = "Location must be at most 200 characters.")]
    public string? Location { get; set; }

    [StringLength(100, ErrorMessage = "City must be at most 100 characters.")]
    public string? City { get; set; }

    [StringLength(100, ErrorMessage = "Country must be at most 100 characters.")]
    public string? Country { get; set; }

    [StringLength(1000, ErrorMessage = "Notes must be at most 1000 characters.")]
    public string? Notes { get; set; }
}

public class UpdateCustomerDto
{
    [StringLength(200, MinimumLength = 1, ErrorMessage = "Customer name must be 1-200 characters.")]
    public string? CustomerName { get; set; }

    [StringLength(20, ErrorMessage = "Phone number must be at most 20 characters.")]
    [Phone(ErrorMessage = "Invalid phone number.")]
    public string? PhoneNumber { get; set; }

    [StringLength(200, ErrorMessage = "Email must be at most 200 characters.")]
    [EmailAddress(ErrorMessage = "Invalid email address.")]
    public string? Email { get; set; }

    [StringLength(200, ErrorMessage = "Location must be at most 200 characters.")]
    public string? Location { get; set; }

    [StringLength(100, ErrorMessage = "City must be at most 100 characters.")]
    public string? City { get; set; }

    [StringLength(100, ErrorMessage = "Country must be at most 100 characters.")]
    public string? Country { get; set; }

    [StringLength(1000, ErrorMessage = "Notes must be at most 1000 characters.")]
    public string? Notes { get; set; }

    public bool? IsActive { get; set; }
}

public class CustomerDetailsDto
{
    public int CustomerId { get; set; }
    public string? CustomerName { get; set; }
    public string? PhoneNumber { get; set; }
    public string? Email { get; set; }
    public string? Location { get; set; }
    public string? City { get; set; }
    public string? Country { get; set; }
    public string? Notes { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class CustomerPagedResponseDto
{
    public IEnumerable<CustomerDetailsDto> Data { get; set; } = Enumerable.Empty<CustomerDetailsDto>();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
}
