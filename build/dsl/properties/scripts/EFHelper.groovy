import com.electriccloud.client.groovy.ElectricFlow

class EFPlugin {
    ElectricFlow ef = new ElectricFlow()

    def getConfiguration(configName) {
        Map configuration = ef.getProperties(path: '/projects/EC-TOPdesk-0.0.2.32/ec_plugin_cfgs/' + configName)?.propertySheet?.property?.collectEntries {
            [it.propertyName, it.value]
        }
        def credential = ef.getFullCredential(credentialName: configName)
        configuration.userName = credential?.credential?.userName
        configuration.password = credential?.credential?.password
        return configuration
    }

    def setProperty_1(propertyName, value) {
        ef.setProperty(propertyName: propertyName, value: value)
    }
}
