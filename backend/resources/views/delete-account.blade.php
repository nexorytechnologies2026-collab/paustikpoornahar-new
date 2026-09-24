@extends('layouts.landing.app')
@section('title', translate('Delete Account'))

@section('content')
    @php($business_name = \App\CentralLogics\Helpers::get_business_settings('business_name') ?? 'Paustik Poornahar')
    @php($support_email = \App\CentralLogics\Helpers::get_business_settings('email_address'))
    @php($support_phone = \App\CentralLogics\Helpers::get_business_settings('phone'))

        <!-- Page Header Gap -->
        <div class="h-148px"></div>
        <!-- Page Header Gap -->

        <section class="privacy-section">
            <div class="container">
                <div class="section-wrapper">
                    <div class="section-wrapper-inner">
                        <div class="section-header mw-100">
                            <h2 class="title"> <span class="text-base">{{ translate('Delete Account') }}</span></h2>
                        </div>
                        <div class="about--content">
                            <p>{{ translate('You can delete your') }} {{ $business_name }} {{ translate('account at any time.') }}</p>

                            <h4>{{ translate('Delete from the app') }}</h4>
                            <ol>
                                <li>{{ translate('Open the app and sign in.') }}</li>
                                <li>{{ translate('Go to Profile.') }}</li>
                                <li>{{ translate('Tap Delete Account and confirm.') }}</li>
                            </ol>
                            <p>{{ translate('If you have an order that is still in progress, finish or cancel it first. The account can be deleted once no order is running.') }}</p>

                            <h4>{{ translate('Ask us to delete it') }}</h4>
                            <p>
                                {{ translate('If you cannot use the app, contact us from your registered email or phone number and ask for your account to be deleted.') }}
                                @if($support_email)
                                    <br>{{ translate('Email') }}: <a href="mailto:{{ $support_email }}">{{ $support_email }}</a>
                                @endif
                                @if($support_phone)
                                    <br>{{ translate('Phone') }}: <a href="tel:{{ $support_phone }}">{{ $support_phone }}</a>
                                @endif
                            </p>

                            <h4>{{ translate('What is deleted') }}</h4>
                            <p>{{ translate('Your profile, saved addresses, favourites and login details are removed. Records of past orders and payments may be kept where the law requires it for tax and accounting.') }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>
@endsection
