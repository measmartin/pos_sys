namespace PosApi.DTOs;

public class ImageUploadResponse
{
    public string ImagePath { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public long FileSize { get; set; }
    public string ContentType { get; set; } = string.Empty;
}

public class ImageDeleteResponse
{
    public bool Success { get; set; }
    public string? Message { get; set; }
}
