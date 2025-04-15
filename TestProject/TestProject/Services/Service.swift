 protocol IService: AnyObject {
    func processData()
}
            
class Service: IService {
    
    private var network: INetwork

    init(network: INetwork) {
        self.network = network
    }

    func processData() {}
}


