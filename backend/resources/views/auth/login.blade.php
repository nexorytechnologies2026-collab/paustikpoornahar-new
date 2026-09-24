<!DOCTYPE html>
    <?php
    $log_email_succ = session()->get('log_email_succ');
    ?>
<html dir="{{ $site_direction }}" lang="{{ $locale }}" class="{{ $site_direction === 'rtl'?'active':'' }}">
<head>
    <!-- Required Meta Tags Always Come First -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    @php
        $app_name = \App\CentralLogics\Helpers::get_business_settings('business_name', false);
        $icon = \App\CentralLogics\Helpers::get_business_settings('icon', false);
    @endphp
    <!-- Title -->
    <title>{{ translate('messages.login') }} | {{$app_name??translate('PAUSTIK POORNAHAR')}}</title>

    <!-- Favicon -->
    <link rel="shortcut icon" href="{{asset($icon ? 'storage/app/public/business/'.$icon : 'public/favicon.ico')}}">

    <!-- Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&amp;display=swap" rel="stylesheet">
    <!-- CSS Implementing Plugins -->
    <link rel="stylesheet" href="{{dynamicAsset('assets/admin')}}/css/vendor.min.css">
    <link rel="stylesheet" href="{{dynamicAsset('assets/admin')}}/vendor/icon-set/style.css">
    <!-- CSS Front Template -->
    <link rel="stylesheet" href="{{dynamicAsset('assets/admin')}}/css/bootstrap.min.css">
    <link rel="stylesheet" href="{{dynamicAsset('assets/admin')}}/css/theme.minc619.css?v=1.0">
    <link rel="stylesheet" href="{{dynamicAsset('assets/admin')}}/css/style.css">
    <link rel="stylesheet" href="{{dynamicAsset('assets/admin')}}/css/toastr.css">
    <style>
        :root {
            --pp-red: #BE0A24;
            --pp-red-dark: #9E0820;
            --pp-ink: #111418;
            --pp-muted: #6B7280;
            --pp-border: #E3E6EA;
        }
        html, body { height: 100%; }
        body { background: #fff; font-family: "Poppins", sans-serif; }

        .pp-login { display: flex; min-height: 100vh; }

        /* Left: photo panel. Drop the photo at public/assets/admin/img/login-bg.jpg */
        .pp-login__visual {
            position: relative;
            flex: 0 0 52.5%;
            background-color: #1b1d1f;
            background-image:
                linear-gradient(180deg, rgba(0, 0, 0, 0) 45%, rgba(0, 0, 0, .65) 100%),
                url("{{ dynamicAsset('assets/admin/img/login-bg.jpg') }}"),
                radial-gradient(rgba(255, 255, 255, .16) 1.2px, transparent 1.3px);
            background-size: cover, cover, 6px 6px;
            background-position: center, center, 0 0;
            filter: grayscale(1);
            overflow: hidden;
        }
        .pp-login__caption {
            position: absolute;
            inset-inline-start: 38px;
            bottom: 40px;
            color: #fff;
            filter: none;
        }
        .pp-login__eyebrow {
            font-size: 12px;
            font-weight: 500;
            letter-spacing: .22em;
            text-transform: uppercase;
            opacity: .85;
            margin-bottom: 14px;
        }
        .pp-login__headline {
            font-size: 42px;
            line-height: 1.15;
            font-weight: 700;
            letter-spacing: -.02em;
            margin: 0;
            color: #fff;
        }

        /* Right: form panel */
        .pp-login__panel {
            flex: 1 1 auto;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px 24px;
        }
        .pp-login__form { width: 100%; max-width: 384px; }
        .pp-login__logo { display: inline-block; margin-bottom: 36px; }
        .pp-login__logo img { width: 236px; max-width: 100%; height: auto; }
        .pp-login__title {
            font-size: 34px;
            line-height: 1.2;
            font-weight: 700;
            letter-spacing: -.02em;
            color: var(--pp-ink);
            margin: 0 0 10px;
        }
        .pp-login__subtitle { font-size: 15px; color: var(--pp-muted); margin: 0 0 36px; }

        .pp-field { margin-bottom: 22px; }
        .pp-field label { display: block; font-size: 13px; font-weight: 500; color: var(--pp-ink); margin-bottom: 8px; }
        .pp-input {
            width: 100%;
            height: 48px;
            padding: 0 16px;
            border: 1px solid var(--pp-border);
            border-radius: 12px;
            font-size: 14px;
            color: var(--pp-ink);
            background: #fff;
            transition: border-color .15s, box-shadow .15s;
        }
        .pp-input::placeholder { color: #8A9099; }
        .pp-input:focus { outline: none; border-color: #0E9E31; box-shadow: 0 0 0 3px rgba(14, 158, 49, .12); }
        .pp-password { position: relative; }
        .pp-password .pp-input { padding-inline-end: 48px; }
        .pp-password__toggle {
            position: absolute;
            inset-inline-end: 6px;
            top: 50%;
            transform: translateY(-50%);
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #4B5563;
            font-size: 18px;
            border-radius: 8px;
        }
        .pp-password__toggle:hover { background: #F3F4F6; color: var(--pp-ink); }

        /* Built-in captcha, also styles the markup that reload-captcha swaps in */
        .pp-captcha { display: flex; gap: 10px; margin: -4px 0 22px; }
        .pp-captcha > div { flex: 1 1 50%; max-width: none; padding: 0; background: transparent !important; }
        .pp-captcha .form-control { height: 48px; border: 1px solid var(--pp-border) !important; border-radius: 12px; font-size: 14px; }
        .pp-captcha img { height: 48px; border: 1px solid var(--pp-border); border-radius: 12px !important; object-fit: cover; }
        .pp-captcha .reloadCaptcha, .pp-captcha #reloadCaptcha { display: flex; align-items: center; padding: 0 0 0 8px !important; cursor: pointer; color: var(--pp-muted); }

        .pp-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 18px; }
        .pp-check { display: inline-flex; align-items: center; gap: 8px; font-size: 13px; color: #4B5563; cursor: pointer; margin: 0; }
        .pp-check input { width: 15px; height: 15px; accent-color: var(--pp-red); margin: 0; }
        .pp-forgot { font-size: 13px; font-weight: 500; color: var(--pp-red); cursor: pointer; background: none; border: 0; padding: 0; }
        .pp-forgot:hover { color: var(--pp-red-dark); text-decoration: underline; }

        .pp-btn {
            display: block;
            width: 100%;
            height: 50px;
            border: 0;
            border-radius: 999px;
            background: var(--pp-red);
            color: #fff;
            font-size: 15px;
            font-weight: 600;
            transition: background .15s, transform .05s;
        }
        .pp-btn:hover { background: var(--pp-red-dark); }
        .pp-btn:active { transform: translateY(1px); }
        .pp-btn:focus-visible { outline: 3px solid rgba(190, 10, 36, .3); outline-offset: 2px; }

        .pp-switch { text-align: center; font-size: 13px; color: var(--pp-muted); margin: 18px 0 0; }
        .pp-switch a { color: #0E9E31; font-weight: 600; }
        .pp-footer { text-align: center; font-size: 12px; color: var(--pp-muted); margin-top: 28px; }
        .pp-footer a { color: var(--pp-muted); }
        .pp-footer a:hover { color: var(--pp-ink); }
        .pp-footer span { margin: 0 8px; opacity: .6; }

        .pp-demo { margin-top: 20px; padding: 12px 14px; border: 1px dashed var(--pp-border); border-radius: 12px; font-size: 13px; }

        @media (max-width: 991px) {
            .pp-login__visual { display: none; }
            .pp-login__panel { padding: 40px 16px; }
        }
        @media (max-width: 480px) {
            .pp-login__title { font-size: 28px; }
            .pp-login__logo img { width: 190px; }
        }
    </style>
</head>

<body>
<!-- ========== MAIN CONTENT ========== -->
@php($role = $role ?? null)
@php($systemlogo = \App\Models\BusinessSetting::where(['key' => 'logo'])->first())
@php($recaptcha = \App\CentralLogics\Helpers::get_business_settings('recaptcha'))
<main id="content" role="main" class="pp-login">
    <section class="pp-login__visual" aria-hidden="true">
        <div class="pp-login__caption">
            <div class="pp-login__eyebrow">{{ $role == 'vendor' ? translate('Restaurant Access') : translate('Staff Access') }}</div>
            <h2 class="pp-login__headline">{{ translate('Homestyle meals,') }}<br>{{ translate('delivered with care.') }}</h2>
        </div>
    </section>

    <section class="pp-login__panel">
        <div class="pp-login__form auth-form-appear">
            <a class="pp-login__logo" href="javascript:">
                <img class="onerror-image"
                     src="{{ \App\CentralLogics\Helpers::get_full_url('business', $systemlogo?->value, $systemlogo?->storage[0]?->value ?? 'public', 'authfav') }}"
                     data-onerror-image="{{ dynamicAsset('assets/admin/img/logo.png') }}"
                     alt="{{ $app_name ?? 'Paustik Poornahar' }}">
            </a>

            <h1 class="pp-login__title">{{ translate('Welcome Back!') }}</h1>
            <p class="pp-login__subtitle">
                @if ($role == 'vendor')
                    {{ translate('Sign in to manage your restaurant, menu, and orders.') }}
                @else
                    {{ translate('Sign in to manage kitchens, orders, and deliveries.') }}
                @endif
            </p>

            <!-- Form -->
            <form class="login_form" action="{{route('login_post')}}" method="post" id="form-id">
                @csrf
                <input type="hidden" name="role" value="{{ $role }}">

                <div class="pp-field">
                    <label for="signinSrEmail">{{ translate('messages.email') }}</label>
                    <input type="email" class="pp-input" value="{{ $email ?? '' }}" name="email" id="signinSrEmail"
                           tabindex="1" placeholder="{{ translate('Enter your email') }}" autocomplete="username"
                           required data-msg="Please enter a valid email address.">
                </div>

                <div class="pp-field">
                    <label for="signupSrPassword">{{ translate('messages.password') }}</label>
                    <div class="pp-password">
                        <input type="password" class="pp-input js-toggle-password" name="password" id="signupSrPassword"
                               value="{{ $password ?? '' }}" tabindex="2" placeholder="{{ translate('Enter your password') }}"
                               autocomplete="current-password" required
                               data-msg="{{translate('messages.invalid_password_warning')}}"
                               data-hs-toggle-password-options='{
                                    "target": "#changePassTarget",
                                    "defaultClass": "tio-hidden-outlined",
                                    "showClass": "tio-visible-outlined",
                                    "classChangeTarget": "#changePassIcon"
                                }'>
                        <a id="changePassTarget" class="pp-password__toggle" href="javascript:" aria-label="{{ translate('Show password') }}">
                            <i id="changePassIcon" class="tio-visible-outlined"></i>
                        </a>
                    </div>
                </div>

                @if(isset($recaptcha) && $recaptcha['status'] == 1)
                    <input type="hidden" name="g-recaptcha-response" id="g-recaptcha-response">
                    <input type="hidden" name="set_default_captcha" id="set_default_captcha_value" value="0">
                    <div class="pp-captcha d-none" id="reload-captcha">
                        <div>
                            <input type="text" class="form-control" name="custome_recaptcha" id="custome_recaptcha" required
                                   placeholder="{{translate('Enter recaptcha value')}}" autocomplete="off"
                                   value="{{env('APP_MODE')=='dev'? session('six_captcha'):''}}">
                        </div>
                        <div class="d-flex">
                            <img src="<?php echo $custome_recaptcha->inline(); ?>" class="w-100" alt="captcha"/>
                            <div class="capcha-spin reloadCaptcha"><i class="tio-cached"></i></div>
                        </div>
                    </div>
                @else
                    <div class="pp-captcha" id="reload-captcha">
                        <div>
                            <input type="text" class="form-control" name="custome_recaptcha" id="custome_recaptcha" required
                                   placeholder="{{translate('Enter recaptcha value')}}" autocomplete="off"
                                   value="{{env('APP_MODE')=='dev'? session('six_captcha'):''}}">
                        </div>
                        <div class="d-flex">
                            <img src="<?php echo $custome_recaptcha->inline(); ?>" class="w-100" alt="captcha"/>
                            <div class="capcha-spin reloadCaptcha"><i class="tio-cached"></i></div>
                        </div>
                    </div>
                @endif

                <div class="pp-row">
                    <label class="pp-check" for="termsCheckbox">
                        <input type="checkbox" id="termsCheckbox" name="remember" {{ $password ? 'checked' : '' }}>
                        {{ translate('messages.remember_me') }}
                    </label>
                    @if ($role == 'admin')
                        <button type="button" class="pp-forgot" data-toggle="modal" data-target="#forgetPassModal">{{ translate('Forget Password') }}</button>
                    @elseif ($role == 'vendor')
                        <button type="button" class="pp-forgot" data-toggle="modal" data-target="#forgetPassModal1">{{ translate('Forget Password') }}</button>
                    @endif
                </div>

                <button type="submit" class="pp-btn" id="signInBtn">{{ translate('messages.login') }}</button>

                @if ($role == 'admin')
                    @php($data = \App\Models\DataSetting::where('type', 'login_restaurant')->pluck('value')->first() ?? 'restaurant')
                    <p class="pp-switch">{{ translate('Login as Restaurant Owner?') }} <a href="{{url('/') }}/login/{{$data}}">{{ translate('Login Here') }}</a></p>
                @endif
                @if ($role == 'vendor')
                    <p class="pp-switch">{{ translate('Don’t have account ?') }} <a href="{{ route('restaurant.create') }}">{{ translate('Registration Here') }}</a></p>
                @endif
            </form>
            <!-- End Form -->

            <div class="pp-footer">
                <a href="{{ route('privacy-policy') }}" target="_blank" rel="noopener">{{ translate('Privacy Policy') }}</a>
                <span>/</span>
                <a href="{{ route('delete-account') }}" target="_blank" rel="noopener">{{ translate('Delete Account') }}</a>
            </div>

            @if(env('APP_MODE') =='demo' )
                @if ($role == 'admin')
                    <div class="pp-demo d-flex align-items-center justify-content-between">
                        <div>
                            <span class="d-block"><strong>Email</strong> : admin@admin.com</span>
                            <span class="d-block"><strong>Password</strong> : 12345678</span>
                        </div>
                        <button class="btn btn-primary m-0" id="copy_cred"><i class="tio-copy"></i></button>
                    </div>
                @endif
                @if ($role == 'vendor')
                    <div class="pp-demo d-flex align-items-center justify-content-between">
                        <div>
                            <span class="d-block"><strong>Email</strong> : test.restaurant@gmail.com</span>
                            <span class="d-block"><strong>Password</strong> : 12345678</span>
                        </div>
                        <button class="btn btn-primary m-0" id="copy_cred2"><i class="tio-copy"></i></button>
                    </div>
                @endif
            @endif
        </div>
    </section>
</main>
<!-- ========== END MAIN CONTENT ========== -->


<div class="modal fade" id="forgetPassModal">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header justify-content-end">
          <span type="button" class="close-modal-icon" data-dismiss="modal">
              <i class="tio-clear"></i>
          </span>
        </div>
        <div class="modal-body">
          <div class="forget-pass-content">
              <img src="{{dynamicAsset('assets/admin/img/send-mail.svg')}}" alt="">
              <h4>
                  {{ translate('Send_Mail_to_Your_Email_?') }}
              </h4>
              <p>
                  {{ translate('A_mail_will_be_send_to_your_registered_email_with_a_link_to_change_passowrd') }}
              </p>
              <a class="btn btn-lg btn-block btn--primary mt-3" href="{{route('reset-password')}}">
                  {{ translate('Send_Mail') }}
              </a>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="modal fade" id="forgetPassModal1">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header justify-content-end">
          <span type="button" class="close-modal-icon" data-dismiss="modal">
              <i class="tio-clear"></i>
          </span>
        </div>
        <div class="modal-body">
          <div class="forget-pass-content">
              <img src="{{dynamicAsset('assets/admin/img/send-mail.svg')}}" alt="">
              <h4>
                  {{ translate('messages.Send_Mail_to_Your_Email_?') }}
              </h4>
              <form class="" action="{{ route('vendor-reset-password') }}" method="post">
                  @csrf

                  <input type="email" name="email" id="" class="form-control" required>
                  <button type="submit" class="btn btn-lg btn-block btn--primary mt-3">{{ translate('messages.Send_Mail') }}</button>
              </form>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="modal fade" id="successMailModal">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header justify-content-end">
            <span type="button" class="close-modal-icon" data-dismiss="modal">
                <i class="tio-clear"></i>
            </span>
          </div>
          <div class="modal-body">
            <div class="forget-pass-content">
                <img src="{{dynamicAsset('assets/admin/img/sent-mail.svg')}}" alt="">
                <h4>
                  {{ translate('Mail Sent to Registered Email Successfully') }}
                </h4>
                <p>
                  {{ translate('An email with password recovery instructions has been sent to your registered email address. Follow the link to reset your password.') }}
                </p>
            </div>
          </div>
        </div>
      </div>
    </div>


<!-- JS Implementing Plugins -->
<script src="{{dynamicAsset('assets/admin')}}/js/vendor.min.js"></script>

<!-- JS Front -->
<script src="{{dynamicAsset('assets/admin')}}/js/theme.min.js"></script>
<script src="{{dynamicAsset('assets/admin')}}/js/toastr.js"></script>
{!! Toastr::message() !!}

@if ($errors->any())
    <script>
        @foreach($errors->all() as $error)
        toastr.error('{{translate($error)}}');
        @endforeach
    </script>
@endif
@if ($log_email_succ)
@php(session()->forget('log_email_succ'))
    <script>
        $('#successMailModal').modal('show');
    </script>
@endif

<script>
    $(document).on('click','.reloadCaptcha', function(){
        $.ajax({
            url: "{{ route('reload-captcha') }}",
            type: "GET",
            dataType: 'json',
            beforeSend: function () {
                $('#loading').show()
                $('.capcha-spin').addClass('active')
            },
            success: function(data) {
                $('#reload-captcha').html(data.view);
            },
            complete: function () {
                $('#loading').hide()
                $('.capcha-spin').removeClass('active')
            }
        });
    });
</script>
<!-- JS Plugins Init. -->
<script>
    $(document).on('ready', function () {
        // INITIALIZATION OF SHOW PASSWORD
        $('.js-toggle-password').each(function () {
            new HSTogglePassword(this).init()
        });

        // INITIALIZATION OF FORM VALIDATION
        $('.js-validate').each(function () {
            $.HSCore.components.HSValidation.init($(this));
        });
    });
</script>

@if(isset($recaptcha) && $recaptcha['status'] == 1)
    <script src="https://www.google.com/recaptcha/api.js?render={{$recaptcha['site_key']}}"></script>
    <script>
        $(document).ready(function() {
            $('#signInBtn').click(function (e) {
                if( $('#set_default_captcha_value').val() == 1){
                    $('#form-id').submit();
                    return true;
                }
                e.preventDefault();
                if (typeof grecaptcha === 'undefined') {
                    toastr.error('Invalid recaptcha key provided. Please check the recaptcha configuration.');
                    $('#reload-captcha').removeClass('d-none');
                    $('#set_default_captcha_value').val('1');

                    return;
                }
                grecaptcha.ready(function () {
                    grecaptcha.execute('{{$recaptcha['site_key']}}', {action: 'submit'}).then(function (token) {
                        $('#g-recaptcha-response').value = token;
                        $('#form-id').submit();
                    });
                });
                window.onerror = function (message) {
                    var errorMessage = 'An unexpected error occurred. Please check the recaptcha configuration';
                    if (message.includes('Invalid site key')) {
                        errorMessage = 'Invalid site key provided. Please check the recaptcha configuration.';
                    } else if (message.includes('not loaded in api.js')) {
                        errorMessage = 'reCAPTCHA API could not be loaded. Please check the recaptcha API configuration.';
                    }
                    $('#reload-captcha').removeClass('d-none');
                    $('#set_default_captcha_value').val('1');
                    toastr.error(errorMessage)
                    return true;
                };
            });
        });
    </script>
@endif
{{-- recaptcha scripts end --}}

@if(env('APP_MODE') =='demo')
    <script>
        $("#copy_cred").click(function() {
            $('#signinSrEmail').val('admin@admin.com');
            $('#signupSrPassword').val('12345678');
            toastr.success('Copied successfully!', 'Success!', {
                CloseButton: true,
                ProgressBar: true
            });
        })
        $("#copy_cred2").click(function() {
            $('#signinSrEmail').val('test.restaurant@gmail.com');
            $('#signupSrPassword').val('12345678');
            toastr.success('Copied successfully!', 'Success!', {
                CloseButton: true,
                ProgressBar: true
            });
        })
    </script>
@endif
</body>
</html>
