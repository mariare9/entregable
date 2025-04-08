# SCRIPT DE DESCARGA DE ARCHIVOS

# Definimos las variables
file_url=$1
output_dir=$2
unzip=$3
filter_word=$4

mkdir -p "$output_dir"
# Obtener el nombre del archivo de la URL. Edto se queda con el ultimo componente despues del ultimo /
filename=$(basename "$file_url")

# Descargar el archivo si no está descargado ya
if [ ! -f /home/vant/Escritorio/Linux/entregablelinux/data/"$filename" ]
then
	echo "Downloading $file_url..."
	wget -P "$output_dir" "$file_url"
fi

# Verificar si la descarga fue exitosa
if [ $? -ne 0 ]
then
	echo "Error downloading the file"
	exit 1
fi

# Manejar la opción de descompresión
if [ "$unzip" = "yes" ]
then
	echo "Uncompressing $filename..."
	gunzip "${output_dir}/${filename}"
	# Actualizar el nombre del archivo (elimina .gz si lo tenía)
	filename="${filename%.gz}"
fi

# Manejar el filtrado de secuencias si se proporciona una palabra de filtro
if [ -n "$filter_word" ];
then
    input_file="${output_dir}/${filename}"
    output_file="${output_dir}/filtered_${filename}"
    
    echo "Filtering sequences excluding those containing '$filter_word'..."
    
    # Usar awk para filtrar las secuencias
    awk -v word="$filter_word" '
        /^>/ {
            if ($0 ~ word) {
               skip = 1
            } else {
                skip = 0
                print
            }
            next
        }
        !skip { print }
    ' "$input_file" > "$output_file"
    
    echo "Filtered sequences saved to $output_file"
fi

echo "Done!"
