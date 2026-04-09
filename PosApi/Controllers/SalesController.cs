using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController][Route("api/[controller]")]
public class SalesController : ControllerBase
{
    private readonly ISalesService _service;

    public SalesController(ISalesService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<SalesPagedResponseDto>> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? search = null,
        [FromQuery] string? status = null)
    {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 20;
        if (pageSize > 200) pageSize = 200;

        var result = await _service.GetPagedAsync(page, pageSize, search, status);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<SalesDetailsDto>> GetById(int id)
    {
        var sale = await _service.GetByIdAsync(id);
        if (sale == null)
            return NotFound();

        return Ok(sale);
    }

    [HttpGet("number/{saleNumber}")]
    public async Task<ActionResult<SalesDetailsDto>> GetBySaleNumber(string saleNumber)
    {
        var sale = await _service.GetBySaleNumberAsync(saleNumber);
        if (sale == null)
            return NotFound();

        return Ok(sale);
    }

    [HttpGet("date-range")]
    public async Task<ActionResult<IEnumerable<SalesDetailsDto>>> GetByDateRange(
        [FromQuery] DateTime startDate, 
        [FromQuery] DateTime endDate)
    {
        var sales = await _service.GetByDateRangeAsync(startDate, endDate);
        return Ok(sales);
    }

    [HttpGet("customer/{customerId}")]
    public async Task<ActionResult<IEnumerable<SalesDetailsDto>>> GetByCustomerId(int customerId)
    {
        var sales = await _service.GetByCustomerIdAsync(customerId);
        return Ok(sales);
    }

    [HttpPost]
    public async Task<ActionResult<int>> Create([FromBody] CreateSalesDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.PhoneNumber))
            return BadRequest(new { message = "Phone number is required for all sales." });

        var id = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id }, id);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> Update(int id, [FromBody] UpdateSalesDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.PhoneNumber))
            return BadRequest(new { message = "Phone number is required for all sales." });

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

    [HttpPost("{saleId}/items")]
    public async Task<ActionResult<int>> AddItem(int saleId, [FromBody] CreateSalesItemDto dto)
    {
        var itemId = await _service.AddItemAsync(saleId, dto);
        return Ok(itemId);
    }

    [HttpPut("{saleId}/items/{itemId}")]
    public async Task<ActionResult> UpdateItem(int saleId, int itemId, [FromBody] UpdateSalesItemDto dto)
    {
        var result = await _service.UpdateItemAsync(saleId, itemId, dto);
        if (!result)
            return NotFound();
        return NoContent();
    }

    [HttpDelete("{saleId}/items/{itemId}")]
    public async Task<ActionResult> RemoveItem(int saleId, int itemId)
    {
        var result = await _service.RemoveItemAsync(saleId, itemId);
        if (!result)
            return NotFound();
        return NoContent();
    }
}
