using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController][Route("api/[controller]")]
public class ProductUnitsController : ControllerBase
{
    private readonly IProductUnitService _service;

    public ProductUnitsController(IProductUnitService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<ProductUnitPagedResponseDto>> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? search = null,
        [FromQuery] int? productId = null,
        [FromQuery] bool? isActive = true)
    {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 20;
        if (pageSize > 200) pageSize = 200;

        var result = await _service.GetPagedAsync(page, pageSize, search, productId, isActive);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProductUnitDetailsDto>> GetById(int id)
    {
        var productUnit = await _service.GetByIdAsync(id);
        if (productUnit == null)
            return NotFound();

        return Ok(productUnit);
    }

    [HttpGet("product/{productId}")]
    public async Task<ActionResult<IEnumerable<ProductUnitDetailsDto>>> GetByProductId(int productId)
    {
        var productUnits = await _service.GetByProductIdAsync(productId);
        return Ok(productUnits);
    }

    [HttpPost]
    public async Task<ActionResult<int>> Create([FromBody] CreateProductUnitDto dto)
    {
        var id = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id }, id);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> Update(int id, [FromBody] UpdateProductUnitDto dto)
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

    [HttpPost("{id}/image")]
    public async Task<ActionResult<ImageUploadResponse>> UploadImage(int id, IFormFile file)
    {
        try
        {
            var response = await _service.UploadImageAsync(id, file);
            return Ok(response);
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { error = $"ProductUnit with ID {id} not found" });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("{id}/image")]
    public async Task<IActionResult> GetImage(int id)
    {
        var imageBytes = await _service.GetImageBytesAsync(id);
        if (imageBytes == null)
            return NotFound();

        return File(imageBytes, "image/webp");
    }

    [HttpDelete("{id}/image")]
    public async Task<ActionResult<ImageDeleteResponse>> DeleteImage(int id)
    {
        var response = await _service.DeleteImageAsync(id);
        if (!response.Success)
            return NotFound(response);

        return Ok(response);
    }
}
