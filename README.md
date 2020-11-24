# beamup

A proof-of-concept OTP+Elixir binary distribution builder, hosting, and installer.

<https://wojtekmach.pl/beamup/>

## Notes

Build with Docker:

```
git clone https://github.com/wojtekmach/beamup
cd beamup
docker run --rm -it -v $PWD:app ubuntu bash
cd /app
apt update && apt install -y curl git build-essential autoconf libncurses-dev libssl-dev
./build_otp 23.1.4
```

Currently we use GitHub as storage for binary artifacts which is not nice. Eventually, we want to attach artifacts to github.com/erlang/otp releases.

## License

Apache-2.0.
