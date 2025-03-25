protocol INetwork: AnyObject {
    func fetchData() -> Data
}
            
class Network: INetwork {
    func fetchData() -> Data {
        return Data()
    }
}