using PosApi.Data;
using PosApi.DTOs;
using PosApi.Models;

namespace PosApi.Services;

public class CustomerService : ICustomerService
{
    private readonly ICustomerRepository _repository;

    public CustomerService(ICustomerRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<CustomerDetailsDto>> GetAllAsync()
    {
        var customers = await _repository.GetAllAsync();
        return customers.Select(MapToDetailsDto);
    }

    public async Task<CustomerPagedResponseDto> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        bool? isActive)
    {
        var (items, totalCount) = await _repository.GetPagedAsync(page, pageSize, search, isActive);
        return new CustomerPagedResponseDto
        {
            Data = items.Select(MapToDetailsDto),
            Page = page,
            PageSize = pageSize,
            TotalCount = totalCount
        };
    }

    public async Task<CustomerDetailsDto?> GetByIdAsync(int id)
    {
        var customer = await _repository.GetByIdAsync(id);
        return customer == null ? null : MapToDetailsDto(customer);
    }

    public async Task<CustomerDetailsDto?> GetByPhoneAsync(string phone)
    {
        var customer = await _repository.GetByPhoneAsync(phone);
        return customer == null ? null : MapToDetailsDto(customer);
    }

    public async Task<int> GetCountAsync()
    {
        return await _repository.GetCountAsync();
    }

    public async Task<int> CreateAsync(CreateCustomerDto dto)
    {
        var customer = new Customer
        {
            CustomerName = dto.CustomerName,
            PhoneNumber = dto.PhoneNumber,
            Email = dto.Email,
            Location = dto.Location,
            City = dto.City,
            Country = dto.Country,
            Notes = dto.Notes,
            IsActive = true,
            CreatedAt = DateTime.Now
        };
        return await _repository.CreateAsync(customer);
    }

    public async Task<bool> UpdateAsync(int id, UpdateCustomerDto dto)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return false;

        if (dto.CustomerName != null) existing.CustomerName = dto.CustomerName;
        if (dto.PhoneNumber != null) existing.PhoneNumber = dto.PhoneNumber;
        if (dto.Email != null) existing.Email = dto.Email;
        if (dto.Location != null) existing.Location = dto.Location;
        if (dto.City != null) existing.City = dto.City;
        if (dto.Country != null) existing.Country = dto.Country;
        if (dto.Notes != null) existing.Notes = dto.Notes;
        if (dto.IsActive.HasValue) existing.IsActive = dto.IsActive.Value;
        existing.UpdatedAt = DateTime.Now;

        return await _repository.UpdateAsync(existing);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        return await _repository.DeleteAsync(id);
    }

    private static CustomerDetailsDto MapToDetailsDto(Customer customer)
    {
        return new CustomerDetailsDto
        {
            CustomerId = customer.CustomerId,
            CustomerName = customer.CustomerName,
            PhoneNumber = customer.PhoneNumber,
            Email = customer.Email,
            Location = customer.Location,
            City = customer.City,
            Country = customer.Country,
            Notes = customer.Notes,
            IsActive = customer.IsActive,
            CreatedAt = customer.CreatedAt,
            UpdatedAt = customer.UpdatedAt
        };
    }
}
