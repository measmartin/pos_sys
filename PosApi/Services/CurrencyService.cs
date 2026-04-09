using PosApi.Data;
using PosApi.DTOs;
using PosApi.Models;

namespace PosApi.Services;

public class CurrencyService : ICurrencyService
{
    private readonly ICurrencyRepository _repository;

    public CurrencyService(ICurrencyRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<CurrencyDetailsDto>> GetAllAsync()
    {
        var currencies = await _repository.GetAllAsync();
        return currencies.Select(MapToDetailsDto);
    }

    public async Task<CurrencyDetailsDto?> GetByIdAsync(int id)
    {
        var currency = await _repository.GetByIdAsync(id);
        return currency == null ? null : MapToDetailsDto(currency);
    }

    public async Task<CurrencyDetailsDto?> GetByCodeAsync(string code)
    {
        var currency = await _repository.GetByCodeAsync(code);
        return currency == null ? null : MapToDetailsDto(currency);
    }

    public async Task<CurrencyDetailsDto?> GetBaseCurrencyAsync()
    {
        var currency = await _repository.GetBaseCurrencyAsync();
        return currency == null ? null : MapToDetailsDto(currency);
    }

    public async Task<int> CreateAsync(CreateCurrencyDto dto)
    {
        var currency = new Currency
        {
            CurrencyCode = dto.CurrencyCode,
            CurrencyName = dto.CurrencyName,
            CurrencySymbol = dto.CurrencySymbol,
            ExchangeRate = dto.ExchangeRate,
            IsBaseCurrency = dto.IsBaseCurrency,
            IsActive = true,
            CreatedAt = DateTime.Now
        };
        return await _repository.CreateAsync(currency);
    }

    public async Task<bool> UpdateAsync(int id, UpdateCurrencyDto dto)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return false;

        if (dto.CurrencyCode != null) existing.CurrencyCode = dto.CurrencyCode;
        if (dto.CurrencyName != null) existing.CurrencyName = dto.CurrencyName;
        if (dto.CurrencySymbol != null) existing.CurrencySymbol = dto.CurrencySymbol;
        if (dto.ExchangeRate.HasValue) existing.ExchangeRate = dto.ExchangeRate.Value;
        if (dto.IsBaseCurrency.HasValue) existing.IsBaseCurrency = dto.IsBaseCurrency.Value;
        if (dto.IsActive.HasValue) existing.IsActive = dto.IsActive.Value;
        existing.UpdatedAt = DateTime.Now;

        return await _repository.UpdateAsync(existing);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        return await _repository.DeleteAsync(id);
    }

    private static CurrencyDetailsDto MapToDetailsDto(Currency currency)
    {
        return new CurrencyDetailsDto
        {
            CurrencyId = currency.CurrencyId,
            CurrencyCode = currency.CurrencyCode,
            CurrencyName = currency.CurrencyName,
            CurrencySymbol = currency.CurrencySymbol,
            ExchangeRate = currency.ExchangeRate,
            IsBaseCurrency = currency.IsBaseCurrency,
            IsActive = currency.IsActive,
            CreatedAt = currency.CreatedAt,
            UpdatedAt = currency.UpdatedAt
        };
    }
}
