local API = {}
local fs = {}
local idFile = nil

function API.init(idfilespace)
    idFile = idfilespace
    return fs
end

function fs.open(filename,mode)
    return io.open(idFile..filename,mode)
end

function fs.exists(filename)
    return HELPER.fileExists(idFile..filename)
end

function fs.makeDir(dirName)
    return core.mkdir(idFile..dirName)
end

function fs.copy(path, dest)
    local file = io.open(idFile..path,"r")
    local data = file:read("a")
    file:close()

    local file = io.open(idFile..dest,"w")
    local copiedSuccess = file:write(data)
    file:close()
    return copiedSuccess
end

function fs.copyDir(path, dest)
    return core.cpdir(idFile..path, idFile..dest)
end

function fs.move(path, dest)
    local file = io.open(idFile..path,"r")
    local data = file:read("a")
    file:close()
    os.remove(idFile..path)

    local file = io.open(idFile..dest,"w")
    local moveSuccess = file:write(data)
    file:close()
    return moveSuccess
end

function fs.isDir(dir)
    return HELPER.dirExists(idFile..dir)
end

function fs.list(path)
    if path == nil then
        return core.get_dir_list(idFile)
    else
        return core.get_dir_list(idFile..path)
    end
end

function fs.delete(file)
    if HELPER.dirExists(idFile..file) then
        core.rmdir(idFile..file, true)
        return true
    elseif HELPER.fileExists(idFile..file) then
        os.remove(idFile..file)
        return true
    end
    return false, "File doesn't exist!"
end

function fs.rename(fromName, toName)
    return os.rename(idFile..fromName, idFile..toName)
end

return API