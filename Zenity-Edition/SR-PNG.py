import sys
import PIL.Image as Image

if __name__ == "__main__":
    input_image_path = sys.argv[1]
    output_image_path = sys.argv[2]

    input_image = Image.open(input_image_path)
    output_image = input_image.resize((512, 512), Image.BICUBIC)
    output_image.save(output_image_path)

