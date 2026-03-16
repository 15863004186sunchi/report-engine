import re
import os

SCHEMA_FILE = 'schema.sql'
BASE_PKG = 'com.report.engine'
ENTITY_DIR = f'src/main/java/com/report/engine/entity'
MAPPER_DIR = f'src/main/java/com/report/engine/mapper'

os.makedirs(ENTITY_DIR, exist_ok=True)
os.makedirs(MAPPER_DIR, exist_ok=True)

def to_camel_case(snake_str, first_upper=False):
    components = snake_str.split('_')
    res = components[0] + ''.join(x.title() for x in components[1:])
    if first_upper:
        res = res[0].upper() + res[1:]
    return res

def sql_type_to_java(sql_type):
    sql_type = sql_type.upper()
    if 'BIGINT' in sql_type: return 'Long'
    if 'INT' in sql_type or 'TINYINT' in sql_type: return 'Integer'
    if 'DECIMAL' in sql_type: return 'BigDecimal'
    if 'DATETIME' in sql_type or 'DATE' in sql_type: return 'LocalDateTime'
    if 'VARCHAR' in sql_type or 'TEXT' in sql_type: return 'String'
    return 'String'

with open(SCHEMA_FILE, 'r', encoding='utf-8') as f:
    sql_content = f.read()

table_blocks = re.split(r'CREATE TABLE', sql_content)[1:]

for block in table_blocks:
    table_name_match = re.search(r'`([^`]+)`', block)
    if not table_name_match: continue
    table_name = table_name_match.group(1)
    class_name = to_camel_case(table_name, True)
    
    fields = []
    has_bigdecimal = False
    has_datetime = False
    
    # parse lines
    lines = block.split('\n')
    for line in lines:
        line = line.strip()
        if line.startswith('`'):
            field_match = re.match(r'`([^`]+)`\s+([A-Z0-9\(\)]+)', line)
            if field_match:
                col_name = field_match.group(1)
                sql_type = field_match.group(2)
                
                comment_match = re.search(r"COMMENT\s+'([^']+)'", line)
                comment = comment_match.group(1) if comment_match else ""
                
                java_type = sql_type_to_java(sql_type)
                if java_type == 'BigDecimal': has_bigdecimal = True
                if java_type == 'LocalDateTime': has_datetime = True
                
                fields.append({
                    'col': col_name,
                    'field': to_camel_case(col_name),
                    'type': java_type,
                    'comment': comment,
                    'is_id': col_name == 'id'
                })

    # Generate Entity
    entity_code = f"package {BASE_PKG}.entity;\n\n"
    entity_code += "import com.baomidou.mybatisplus.annotation.IdType;\n"
    entity_code += "import com.baomidou.mybatisplus.annotation.TableId;\n"
    entity_code += "import com.baomidou.mybatisplus.annotation.TableName;\n"
    entity_code += "import lombok.Data;\n"
    if has_bigdecimal: entity_code += "import java.math.BigDecimal;\n"
    if has_datetime: entity_code += "import java.time.LocalDateTime;\n"
    entity_code += "\n@Data\n"
    entity_code += f"@TableName(\"{table_name}\")\n"
    entity_code += f"public class {class_name} {{\n"
    
    for f in fields:
        if f['comment']:
            entity_code += f"    /**\n     * {f['comment']}\n     */\n"
        if f['is_id']:
            entity_code += f"    @TableId(type = IdType.AUTO)\n"
        entity_code += f"    private {f['type']} {f['field']};\n\n"
        
    entity_code += "}\n"
    
    with open(f"{ENTITY_DIR}/{class_name}.java", "w", encoding="utf-8") as java_file:
        java_file.write(entity_code)

    # Generate Mapper
    mapper_code = f"package {BASE_PKG}.mapper;\n\n"
    mapper_code += f"import {BASE_PKG}.entity.{class_name};\n"
    mapper_code += "import com.baomidou.mybatisplus.core.mapper.BaseMapper;\n"
    mapper_code += "import org.apache.ibatis.annotations.Mapper;\n\n"
    mapper_code += "@Mapper\n"
    mapper_code += f"public interface {class_name}Mapper extends BaseMapper<{class_name}> {{\n"
    mapper_code += "}\n"
    
    with open(f"{MAPPER_DIR}/{class_name}Mapper.java", "w", encoding="utf-8") as mapper_file:
        mapper_file.write(mapper_code)

print("Entities and Mappers generated successfully.")
