using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class CustomersController : ControllerBase
{
    private readonly ICustomerService _service;

    public CustomersController(ICustomerService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<CustomerPagedResponseDto>> GetAll(
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
    public async Task<ActionResult<CustomerDetailsDto>> GetById(int id)
    {
        var customer = await _service.GetByIdAsync(id);
        if (customer == null)
            return NotFound();

        return Ok(customer);
    }

    [HttpGet("phone/{phone}")]
    public async Task<ActionResult<CustomerDetailsDto>> GetByPhone(string phone)
    {
        var customer = await _service.GetByPhoneAsync(phone);
        if (customer == null)
            return NotFound();

        return Ok(customer);
    }

    [HttpPost]
    public async Task<ActionResult<int>> Create([FromBody] CreateCustomerDto dto)
    {
        var id = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id }, id);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> Update(int id, [FromBody] UpdateCustomerDto dto)
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
