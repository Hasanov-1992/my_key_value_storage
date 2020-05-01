defmodule CrossTest do
  use ExUnit.Case, async: false
  use Plug.Test

  test "Добавить запись в хранилищи" do
    Storage.delete("key")
    assert Storage.read("key") == "Такой запись не существует"
    assert Storage.create("key", "value", 40000) == "Запись value добавлена"
    assert Storage.read("key") == "value"
  end

  test "Если запись существует в хранилищи" do
    Storage.delete("key")
    assert Storage.create("key", "value", 3000000) == "Запись value добавлена"
    assert Storage.create("key", "value", 3000000) == "Такой запись уже существует"
  end

  test "Проверка ttl" do
    assert Storage.create("key", "vakue", -900000) == "TTL должен быть равно либо больше нуля"
  end

  test "Читать запись из хранилищи" do
    Storage.create("key", "value", 40000)
    assert Storage.read("key") == "value"
  end

  test "Обновить запись в хранилищи" do
    Storage.delete("key")
    assert Storage.create("key", "value", 35000) == "Запись value добавлена"
    assert Storage.read("key") == "value"
    assert Storage.update("key", "new_value") == "Изменение значение на new_value"
    assert Storage.read("key") == "new_value"
  end

  test "Удалить запись из хранилищи" do
    Storage.create("key1", "value1", 40000)
    assert Storage.delete("key1") == "Запись key1 удалена"
    assert Storage.read("key1") == "Такой запись не существует"
  end

  test "Проверить, существует ли запись после открытия / закрытия хранилища" do
    Storage.delete("20sec")
    assert Storage.create("20sec", "20000", 20000) == "Запись 20000 добавлена"
    assert Storage.read("20sec")  == "20000"
  end

  test "Post" do
    resp = conn(:post, "/", %{key: 7, value: "seven", ttl: 5000})
    |> Cross.Router.call([])
    assert resp.status == 200
    assert resp.resp_body == "\"Запись seven добавлена\""
  end

  test "GET" do
    resp = conn(:get, "/", %{key: 1})
    |> Cross.Router.call([])
    assert resp.status == 200
    assert resp.resp_body == "\"one\""
  end

  test "PUT" do
    resp = conn(:put, "/", %{key: 3, value: "three"})
    |> Cross.Router.call([])
    assert resp.status == 200
    assert resp.resp_body == "\"Изменение значение на three\""
  end

  test "DELETE" do
    resp = conn(:delete, "/", %{key: 7})
    |> Cross.Router.call([])
    assert resp.status == 200
    assert resp.resp_body == "\"Запись 7 удалена\""
  end

  test "Проверка 404 ошибка" do
    resp = conn(:method, "/", %{key: 7})
    |> Cross.Router.call([])
    assert resp.status == 404
    assert resp.resp_body == "Oops!"
  end

end
