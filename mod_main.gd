extends Node

var CUE := load("res://mods-unpacked/Multrapool-Cue/cue.gd")

# Name of the directory that this file is in, and full ID of the mod (AuthorName-ModName)
const MOD_ID := "kyfex-more_cosmetics"

var mod_dir_path := ""
var extensions_dir_path := ""

var cosmetics_folder = OS.get_executable_path().get_base_dir()+"/kyfex-more_cosmetics/"

# your _ready func.
func _init() -> void:
    ModLoaderLog.info("Init", MOD_ID)
    mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_ID)
    extensions_dir_path = mod_dir_path.path_join("extensions")
    
    for subfolder in [
        "color",
        "floor",
        "table",
        "wall"
    ]:
        DirAccess.make_dir_recursive_absolute(
            OS.get_executable_path().get_base_dir()+"/kyfex-more_cosmetics/"+subfolder)

    # Add extensions
    install_script_extensions()
    install_script_hook_files()

    # Load translations for your mod, if you need them.
    # Add translations by adding a CSV called "AuthorName-ModName.csv" into the "translations" directory.
    # Godot will automatically generate a ".translation" file, eg "AuthorName-ModName.en.translation".
    # Note that in this example, only the file called "AuthorName-ModName.csv" is custom
    #ModLoaderMod.add_translation(mod_dir_path.path_join("AuthorName-ModName.en.translation"))


func install_script_extensions() -> void:
    pass
    # any script extensions should go in /extensions, and should follow the same directory structure as vanilla

    # ? Brief description/reason behind this edit of vanilla code...
    #ModLoaderMod.install_script_extension(extensions_dir_path.path_join("utils/utils.gd"))


func install_script_hook_files() -> void:
    ModLoaderMod.add_hook(load_resources_hook, "res://utils/utils.gd", "load_resources_from_folder")
    
    # ? Brief description/reason behind this edit of vanilla code...
    #ModLoaderMod.install_script_hooks("res://main.gd", extensions_dir_path.path_join("main.gd"))


func _ready() -> void:
    ModLoaderLog.info("Ready", MOD_ID)


func load_resources_hook(chain: ModLoaderHookChain, path: String, extension: String = "tres", key_func: Callable = Callable()) -> Dictionary:
    var orig = chain.execute_next([path, extension, key_func])
    
    if path.begins_with("res://data/cosmetics/"):
        var custom_files = []
        for subfolder in [
            "color",
            "floor",
            "table",
            "wall"
        ]:
            var files = DirAccess.get_files_at(cosmetics_folder+subfolder)
            for file in files:
                custom_files.append({
                    file_name=file,
                    short_name=".".join(file.get_file().split(".").slice(0,-1)),
                    type=subfolder
                })
        
        for file_data in custom_files:
            var resource:=Cosmetic.new()
            print(file_data.file_name)
            match file_data.type:
                "color":
                    resource.title=file_data.short_name
                    resource.type=Cosmetic.COSMETIC_TYPE.GRADIENT
                    resource.extra_resource=TableColor.new()
                    resource.extra_resource.colors.assign(Array(FileAccess.get_file_as_string(cosmetics_folder+file_data.type+"/"+file_data.file_name)\
                        .split("\n")).filter(func(color:String):return color.length() != 0).map(func(colorstring:String): return Color.from_string(colorstring,Color.WEB_GREEN)))
                    resource.id="KYFEX_MORECOSMETICS_COLOR_"+file_data.short_name
                "floor":
                    resource.title=file_data.short_name
                    resource.type=Cosmetic.COSMETIC_TYPE.SHOP_FLOOR
                    resource.texture=ImageTexture.create_from_image(Image.load_from_file(cosmetics_folder+file_data.type+"/"+file_data.file_name))
                    resource.id="KYFEX_MORECOSMETICS_FLOOR_"+file_data.short_name
                "table":
                    resource.title=file_data.short_name
                    resource.type=Cosmetic.COSMETIC_TYPE.TABLE_MAIN
                    resource.texture=ImageTexture.create_from_image(Image.load_from_file(cosmetics_folder+file_data.type+"/"+file_data.file_name))
                    resource.id="KYFEX_MORECOSMETICS_FLOOR_"+file_data.short_name
                "wall":
                    resource.title=file_data.short_name
                    resource.type=Cosmetic.COSMETIC_TYPE.TABLE_WALLS
                    resource.texture=ImageTexture.create_from_image(Image.load_from_file(cosmetics_folder+file_data.type+"/"+file_data.file_name))
                    resource.id="KYFEX_MORECOSMETICS_WALLS_"+file_data.short_name
            
            var key: String
            if key_func.is_valid():
                key = key_func.call(resource, file_data.file_name)
            else:
                key = file_data.file_name
            orig[key] = resource
    
    return orig
