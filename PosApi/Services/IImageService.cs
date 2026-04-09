using PosApi.DTOs;

namespace PosApi.Services;

public interface IImageService
{
    Task<ImageUploadResponse> UploadImageAsync(IFormFile file, int productUnitId);
    Task<ImageDeleteResponse> DeleteImageAsync(string imagePath);
    Task<byte[]?> GetImageBytesAsync(string imagePath);
}
