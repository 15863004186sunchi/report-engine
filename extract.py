import docx
import sys

def main():
    try:
        doc = docx.Document("e:/antigravityPro/report-engine/部门报表需求.docx")
        text = []
        for para in doc.paragraphs:
            text.append(para.text)
        
        with open("e:/antigravityPro/report-engine/extracted_text.txt", "w", encoding="utf-8") as f:
            f.write("\n".join(text))
        print("Extraction successful")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
