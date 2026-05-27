export interface ImageUploadResponse {
  imagePath: string;
  imageUrl: string;
  fileSize: number;
  contentType: string;
}

export interface ImageDeleteResponse {
  success: boolean;
  message?: string | null;
}
