 protocol IService: AnyObject {
    func processData()
}
            
class Service: IService {
    
    private let network: INetwork

    init(network: INetwork) {
        self.network = network
    }

    func processData() {}
}