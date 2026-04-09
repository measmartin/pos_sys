using PosApi.DTOs;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Webp;
using SixLabors.ImageSharp.Processing;

namespace PosApi.Services;

public class ImageService : IImageService
{
    private readonly IWebHostEnvironment _environment;
    private readonly IConfiguration _configuration;
    private readonly string _imageFolder;
    private readonly long _maxFileSize;
    private readonly int _maxWidth;
    private readonly int _maxHeight;
    private readonly int _quality;
    private readonly string[] _allowedExtensions;

    public ImageService(IWebHostEnvironment environment, IConfiguration configuration)
    {
        _environment = environment;
        _configuration = configuration;
        
        _imageFolder = Path.Combine(_environment.ContentRootPath, _configuration["ImageSettings:ImageFolder"] ?? "wwwroot/images/products");
        _maxFileSize = long.Parse(_configuration["ImageSettings:MaxFileSizeBytes"] ?? "1048576");
        _maxWidth = int.Parse(_configuration["ImageSettings:MaxWidth"] ?? "1920");
        _maxHeight = int.Parse(_configuration["ImageSettings:MaxHeight"] ?? "1920");
        _quality = int.Parse(_configuration["ImageSettings:Quality"] ?? "80");
        _allowedExtensions = _configuration.GetSection("ImageSettings:AllowedExtensions").Get<string[]>() ?? new[] { ".jpg", ".jpeg", ".png", ".webp" };
        
        if (!Directory.Exists(_imageFolder))
        {
            Directory.CreateDirectory(_imageFolder);
        }
    }

    public async Task<ImageUploadResponse> UploadImageAsync(IFormFile file, int productUnitId)
    {
        if (file == null || file.Length == 0)
        {
            throw new ArgumentException("No file provided");
        }

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!_allowedExtensions.Contains(extension))
        {
            throw new InvalidOperationException($"Only {string.Join(", ", _allowedExtensions)} images are allowed");
        }

        if (file.Length > _maxFileSize * 2)
        {
            throw new InvalidOperationException($"File size exceeds maximum allowed size ({_maxFileSize / 1024 / 1024} MB)");
        }

        var timestamp = DateTime.Now.ToString("yyyyMMddHHmmssfff");
        var fileName = $"{productUnitId}_{timestamp}";
        var finalPath = Path.Combine(_imageFolder, $"{fileName}.webp");
        var relativePath = $"images/products/{fileName}.webp";

        using var image = await Image.LoadAsync(file.OpenReadStream());

        if (image.Width > _maxWidth || image.Height > _maxHeight)
        {
            image.Mutate(x => x.Resize(new ResizeOptions
            {
                Mode = ResizeMode.Max,
                Size = new Size(_maxWidth, _maxHeight)
            }));
        }

        var encoder = new WebpEncoder
        {
            Quality = _quality
        };

        await image.SaveAsync(finalPath, encoder);

        var fileInfo = new FileInfo(finalPath);
        if (fileInfo.Length > _maxFileSize)
        {
            File.Delete(finalPath);
            throw new InvalidOperationException("Compressed image still exceeds maximum size");
        }

        var baseUrl = _configuration["BaseUrl"] ?? "https://localhost:7070";
        
        return new ImageUploadResponse
        {
            ImagePath = relativePath,
            ImageUrl = $"{baseUrl}/{relativePath}",
            FileSize = fileInfo.Length,
            ContentType = "image/webp"
        };
    }

    public async Task<ImageDeleteResponse> DeleteImageAsync(string imagePath)
    {
        if (string.IsNullOrEmpty(imagePath))
        {
            return new ImageDeleteResponse { Success = false, Message = "No image path provided" };
        }

        var fullPath = Path.Combine(_environment.ContentRootPath, imagePath.Replace('/', Path.DirectorySeparatorChar));
        
        if (!File.Exists(fullPath))
        {
            return new ImageDeleteResponse { Success = false, Message = "Image file not found" };
        }

        try
        {
            File.Delete(fullPath);
            return new ImageDeleteResponse { Success = true, Message = "Image deleted successfully" };
        }
        catch (Exception ex)
        {
            return new ImageDeleteResponse { Success = false, Message = $"Failed to delete image: {ex.Message}" };
        }
    }

    public async Task<byte[]?> GetImageBytesAsync(string imagePath)
    {
        if (string.IsNullOrEmpty(imagePath))
        {
            return null;
        }

        var fullPath = Path.Combine(_environment.ContentRootPath, imagePath.Replace('/', Path.DirectorySeparatorChar));
        
        if (!File.Exists(fullPath))
        {
            return null;
        }

        return await File.ReadAllBytesAsync(fullPath);
    }
}
