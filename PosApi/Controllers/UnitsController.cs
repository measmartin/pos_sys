using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController][Route("api/[controller]")]
public class UnitsController : ControllerBase
{
    private readonly IUnitService _service;

    public UnitsController(IUnitService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<UnitDetailsDto>>> GetAll()
    {
        var units = await _service.GetAllAsync();
        return Ok(units);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<UnitDetailsDto>> GetById(int id)
    {
        var unit = await _service.GetByIdAsync(id);
        if (unit == null)
            return NotFound();

        return Ok(unit);
    }

    [HttpPost]
    public async Task<ActionResult<int>> Create([FromBody] CreateUnitDto dto)
    {
        var id = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id }, id);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> Update(int id, [FromBody] UpdateUnitDto dto)
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
