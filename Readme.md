> [!CAUTION]
> **This is a community-made unofficial image, and is NOT endorsed by CubeCoders.**
> **Please DO NOT ask CubeCoders for support if you use this image. They do not support nor endorse this image and will understandably tell you that you are on your own.**
> 
> This project is community driven by people who have full time responsibilities elsewhere. You should be able to navigate Docker, Linux, bash, etc. and feel comfortable debugging containers on your own if you intend to use this image.
>
> That said, if you have time and are able to help, please feel free! I love PRs!

> [!NOTE]
> This Image Requires The Following Enviroment Variables

| Variable | Description | Default Value |
|---|---|---|
| `AMP_LICENCE` | Your official CubeCoders AMP License key required on first boot. | *None* |
| `AMP_USERNAME` | The username of the admin user created on first boot. | `admin` |
| `AMP_PASSWORD` | The password of the admin user. This value is only used when creating the new user. If you use the default value, please change it after first sign-in. | `ChangeMe123!` |
| `AMP_PORT` | The internal container port that the main AMP Web UI instance binds to. | `8080` |
| `HOST_PORT` | The external host port mapped to the AMP Web UI. | `8080` |
| `SFTP_PORT` | The external host port mapped to the AMP SFTP management service. | `2223` |


> [!NOTE]
> This image includes the following Java versions:
> - **Java 25** (Eclipse Temurin JDK) — *System Default*
> - **Java 24** (Eclipse Temurin JDK)
> - **Java 23** (Eclipse Temurin JDK)
> - **Java 22** (Eclipse Temurin JDK)
> - **Java 21** (Eclipse Temurin JDK)
> - **Java 17** (Eclipse Temurin JDK)
> - **Java 11** (Eclipse Temurin JDK)
> - **Java 8** (Eclipse Temurin JDK)

> [!NOTE]  
AMP (Application Management Panel) allows you to manage one or more game servers from a web UI. You need a [CubeCoders AMP Licence](https://cubecoders.com/AMP) to use AMP; this image does not bypass that requirement.

> [!WARNING]
> **This is a community-made unofficial image, and is not endorsed by CubeCoders.**

> [!WARNING]
> **Please DO NOT ask CubeCoders for support. They do not support nor endorse this image and will tell you that you are on your own.**
