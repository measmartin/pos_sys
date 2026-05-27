using PosApi.Data;
using PosApi.DTOs;
using PosApi.Models;

namespace PosApi.Services;

public class UnitService : IUnitService
{
    private readonly IUnitRepository _repository;

    public UnitService(IUnitRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<UnitDetailsDto>> GetAllAsync()
    {
        var units = await _repository.GetAllAsync();
        return units.Select(MapToDetailsDto);
    }

    public async Task<UnitPagedResponseDto> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        bool? isActive)
    {
        var (items, totalCount) = await _repository.GetPagedAsync(page, pageSize, search, isActive);
        return new UnitPagedResponseDto
        {
            Data = items.Select(MapToDetailsDto),
            Page = page,
            PageSize = pageSize,
            TotalCount = totalCount
        };
    }

    public async Task<UnitDetailsDto?> GetByIdAsync(int id)
    {
        var unit = await _repository.GetByIdAsync(id);
        return unit == null ? null : MapToDetailsDto(unit);
    }

    public async Task<int> CreateAsync(CreateUnitDto dto)
    {
        var unit = new Unit
        {
            UnitName = dto.UnitName,
            UnitCode = dto.UnitCode,
            Description = dto.Description,
            IsActive = true,
            CreatedAt = DateTime.Now
        };
        return await _repository.CreateAsync(unit);
    }

    public async Task<bool> UpdateAsync(int id, UpdateUnitDto dto)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return false;

        if (dto.UnitName != null) existing.UnitName = dto.UnitName;
        if (dto.UnitCode != null) existing.UnitCode = dto.UnitCode;
        if (dto.Description != null) existing.Description = dto.Description;
        if (dto.IsActive.HasValue) existing.IsActive = dto.IsActive.Value;
        existing.UpdatedAt = DateTime.Now;

        return await _repository.UpdateAsync(existing);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        return await _repository.DeleteAsync(id);
    }

    private static UnitDetailsDto MapToDetailsDto(Unit unit)
    {
        return new UnitDetailsDto
        {
            UnitId = unit.UnitId,
            UnitName = unit.UnitName,
            UnitCode = unit.UnitCode,
            Description = unit.Description,
            IsActive = unit.IsActive,
            CreatedAt = unit.CreatedAt,
            UpdatedAt = unit.UpdatedAt
        };
    }
}
