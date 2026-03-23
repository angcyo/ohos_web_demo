use wasm_bindgen::prelude::wasm_bindgen;
use wasm_bindgen::JsValue;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026-03-23
///
/// https://napi.rs/docs/concepts/values

/// 测试布尔类型的参数传输
/// @return 取反
#[wasm_bindgen]
pub fn test_bool(value: bool) -> bool {
    !value
}

/// 测试整数类型的参数传输
#[wasm_bindgen]
pub fn test_int(value: i32) -> i32 {
    value
}

/// 测试双精度浮点类型的参数传输
#[wasm_bindgen]
pub fn test_double(value: f64) -> f64 {
    value
}

/// 测试字符串类型的参数传输
#[wasm_bindgen]
pub fn test_string(value: String) -> String {
    String::from(value.to_string())
}

#[wasm_bindgen]
pub fn test_str(value: &str) -> String {
    String::from(value.to_string())
}

/// 测试字节类型的参数传输
#[wasm_bindgen]
pub fn test_bytes(value: Vec<u8>) -> Vec<u8> {
    Vec::from(value.to_vec())
}

#[wasm_bindgen]
pub fn test_box(value: Box<[JsValue]>) -> Box<[JsValue]> {
    // 1. 将 Box<[JsValue]> 转为 Vec<JsValue> 以便动态修改
    let mut vec_data = value.into_vec();

    // 2. 创建一个包含前置数据的 Vec
    let mut result = vec![JsValue::NULL, JsValue::UNDEFINED];

    // 3. 将原数据追加到新 Vec 中（类似于 JS 的 [...value]）
    result.append(&mut vec_data);

    // 4. 转回 Box<[JsValue]> 返回给 JS
    result.into_boxed_slice()
}

#[wasm_bindgen]
pub fn test_buffer(ptr: *mut u8, len: usize) -> *mut u8 {
    // 1. 将裸指针转换为 Rust 的切片（Slice）
    // 安全提示：调用者必须确保 ptr 有效且 len 正确
    let data = unsafe { std::slice::from_raw_parts_mut(ptr, len) };

    // 2. 枚举并处理数据 (例如：每个字节加 1)
    for byte in data.iter_mut() {
        *byte = byte.wrapping_add(1);
    }

    // 3. 返回指针（在 Wasm 中通常返回原指针或新分配的指针）
    ptr
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_func() {
        println!("test_bool->{}", test_bool(true));
        println!("test_int->{}", test_int(1));
        println!("test_double->{}", test_double(1.1));
        println!("test_string->{}", test_string(String::from("test_string")));
        println!("test_bytes->{}", test_bytes(Vec::from(vec![1, 2, 3])).len());
    }
}
