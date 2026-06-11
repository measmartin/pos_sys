using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _service;

    public ProductsController(IProductService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<ProductPagedResponseDto>> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? search = null,
        [FromQuery] int? categoryId = null,
        [FromQuery] bool? isActive = true)
    {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 20;
        if (pageSize > 200) pageSize = 200;

        var result = await _service.GetPagedAsync(page, pageSize, search, categoryId, isActive);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProductDetailsDto>> GetById(int id)
    {
        var product = await _service.GetByIdAsync(id);
        if (product == null)
            return NotFound();

        return Ok(product);
    }

    [HttpGet("category/{categoryId}")]
    public async Task<ActionResult<IEnumerable<ProductDetailsDto>>> GetByCategoryId(int categoryId)
    {
        var products = await _service.GetByCategoryIdAsync(categoryId);
        return Ok(products);
    }

    [HttpPost]
    public async Task<ActionResult<int>> Create([FromBody] CreateProductDto dto)
    {
        var id = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id }, id);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> Update(int id, [FromBody] UpdateProductDto dto)
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
