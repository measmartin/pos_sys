using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController][Route("api/[controller]")]
public class CurrenciesController : ControllerBase
{
    private readonly ICurrencyService _service;

    public CurrenciesController(ICurrencyService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<CurrencyPagedResponseDto>> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? search = null,
        [FromQuery] bool? isActive = true)
    {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 20;
        if (pageSize > 200) pageSize = 200;

        var result = await _service.GetPagedAsync(page, pageSize, search, isActive);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<CurrencyDetailsDto>> GetById(int id)
    {
        var currency = await _service.GetByIdAsync(id);
        if (currency == null)
            return NotFound();

        return Ok(currency);
    }

    [HttpGet("code/{code}")]
    public async Task<ActionResult<CurrencyDetailsDto>> GetByCode(string code)
    {
        var currency = await _service.GetByCodeAsync(code);
        if (currency == null)
            return NotFound();

        return Ok(currency);
    }

    [HttpPost]
    public async Task<ActionResult<int>> Create([FromBody] CreateCurrencyDto dto)
    {
        var id = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id }, id);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> Update(int id, [FromBody] UpdateCurrencyDto dto)
    {
        var result = await _service.UpdateAsync(id, dto);
        if (!result)
            return NotFound();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> Delete(int id)
    {
        var result = await _service.DeleteAsync(id);
        if (!result)
            return NotFound();

        return NoContent();
    }
}
