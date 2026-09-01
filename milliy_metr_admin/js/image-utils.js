/**
 * Image compression utility
 * Reduces image dimensions and size before uploading to server
 * This drastically improves mobile app performance
 */

const ImageCompressor = {
  /**
   * Compress an image file
   * @param {File} file - Original image file
   * @param {Object} options - Compression options
   * @returns {Promise<File>} Compressed image file
   */
  async compress(file, options = {}) {
    const {
      maxWidth = 1024,
      maxHeight = 1024,
      quality = 0.8,
      mimeType = 'image/webp'
    } = options;

    // Only compress images
    if (!file.type.startsWith('image/')) {
      return file;
    }

    // Don't compress SVGs or Gifs
    if (file.type === 'image/svg+xml' || file.type === 'image/gif') {
      return file;
    }

    return new Promise((resolve, reject) => {
      const img = new Image();
      const url = URL.createObjectURL(file);
      
      img.onload = () => {
        URL.revokeObjectURL(url);
        
        let width = img.width;
        let height = img.height;
        
        // Calculate new dimensions while maintaining aspect ratio
        if (width > maxWidth || height > maxHeight) {
          const ratio = Math.min(maxWidth / width, maxHeight / height);
          width = width * ratio;
          height = height * ratio;
        }
        
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        
        const ctx = canvas.getContext('2d');
        // Fill white background for transparent images converted to JPEG
        if (mimeType === 'image/jpeg' && file.type === 'image/png') {
           ctx.fillStyle = '#FFFFFF';
           ctx.fillRect(0, 0, width, height);
        }
        ctx.drawImage(img, 0, 0, width, height);
        
        canvas.toBlob((blob) => {
          if (!blob) {
            reject(new Error('Canvas to Blob conversion failed'));
            return;
          }
          
          // Create new file from blob
          const newFileName = file.name.replace(/\.[^/.]+$/, "") + (mimeType === 'image/webp' ? '.webp' : '.jpg');
          const compressedFile = new File([blob], newFileName, {
            type: mimeType,
            lastModified: Date.now()
          });
          
          resolve(compressedFile);
        }, mimeType, quality);
      };
      
      img.onerror = () => {
        URL.revokeObjectURL(url);
        // If image fails to load in canvas, just return original file
        resolve(file);
      };
      
      img.src = url;
    });
  }
};
